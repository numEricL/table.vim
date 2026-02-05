let s:cell_bufnr = -1
let s:tbls = {}
let s:tbl_id = -1

function! s:FindWindow(bufnr) abort
    for winnr in range(1, winnr('$'))
        if winbufnr(winnr) == a:bufnr
            return winnr
        endif
    endfor
    return -1
endfunction

function! s:CachedBuf() abort
    if s:cell_bufnr == -1 || !bufexists(s:cell_bufnr)
        let s:cell_bufnr = bufadd('')
        call setbufvar(s:cell_bufnr, '&buftype', 'nofile')
        call setbufvar(s:cell_bufnr, '&bufhidden', 'hide')
        call setbufvar(s:cell_bufnr, '&swapfile', 0)
    endif
    return s:cell_bufnr
endfunction

function! s:InitBuffer(lines) abort
    let current_bufnr = bufnr('%')
    let bufnr = s:CachedBuf()
    call setbufvar(bufnr, '&filetype', getbufvar(current_bufnr, '&filetype'))

    let old_undolevels = getbufvar(bufnr, '&undolevels')
    call setbufvar(bufnr, '&undolevels', -1)
    call bufload(bufnr)
    call setbufline(bufnr, 1, a:lines)
    call setbufvar(bufnr, '&undolevels', old_undolevels)

    return bufnr
endfunction

function! s:InitWindow(bufnr, textobj) abort
    let winnr = s:FindWindow(a:bufnr)
    if winnr == -1
        let screenpos = screenpos(win_getid(), a:textobj.start[0], a:textobj.start[1])
        split
        let winnr = winnr()
        call setwinvar(winnr, '&number', 0)
        call setwinvar(winnr, '&relativenumber', 0)
        call setwinvar(winnr, '&scrolloff', 0)
        call setwinvar(winnr, '&sidescrolloff', 0)
        execute 'buffer ' .. a:bufnr
    else
        execute winnr .. 'wincmd w'
    endif
    return winnr
endfunction

function! s:UpdateCell(tbl, cell_id, bufnr) abort
    let lines = getbufline(a:bufnr, 1, '$')
    call a:tbl.SetCell(a:cell_id[0], a:cell_id[1], lines)
endfunction

function! s:SetWindowAutocmds(tbl, cell_id, winnr, bufnr) abort
    let s:tbl_id += 1
    let s:tbls[s:tbl_id] = {
                \ 'table': a:tbl,
                \ 'cell_id': a:cell_id,
                \ 'winnr': a:winnr,
                \ 'bufnr': a:bufnr,
                \ }

    augroup table.vim
        execute 'autocmd WinLeave <buffer=' .. a:bufnr .. '> call s:OnWinLeave(' .. s:tbl_id .. ')'
        execute 'autocmd WinClosed <buffer=' .. a:bufnr .. '> call s:OnWinClosed(' .. s:tbl_id .. ')'
    augroup END
endfunction

function! s:OnWinLeave(tbl_id) abort
    let tbl = s:tbls[a:tbl_id].table
    let cell_id = s:tbls[a:tbl_id].cell_id
    let winnr = s:tbls[a:tbl_id].winnr
    let bufnr = s:tbls[a:tbl_id].bufnr

    " Close the window
    if winnr() == winnr
        close
    endif
endfunction

function! s:OnWinClosed(tbl_id) abort
    let tbl = s:tbls[a:tbl_id].table
    let cell_id = s:tbls[a:tbl_id].cell_id
    let winnr = s:tbls[a:tbl_id].winnr
    let bufnr = s:tbls[a:tbl_id].bufnr

    let closed_winid = str2nr(expand('<amatch>'))
    if closed_winid != win_getid(winnr)
        return
    endif

    let g:TableCellEditData = {'bufnr': bufnr, 'winid': win_getid(winnr), 'table': tbl, 'cell_id': cell_id}
    if exists('#User#TableCellEditPost')
        doautocmd User TableCellEditPost
    endif

    call s:UpdateCell(tbl, cell_id, bufnr)
    call table#draw#CurrentlyPlaced(tbl)
    augroup table.vim
        autocmd!
    augroup END
endfunction

function! s:EditCell(tbl, cell_id) abort
    let cell = a:tbl.Cell(a:cell_id[0], a:cell_id[1])
    let bufnr = s:InitBuffer(cell)

    let textobj = table#textobj#Cell(1, 'inner')
    let pos = [line('.'), col('.')]
    let pos = [pos[0] - textobj['start'][0] + 1, pos[1] - textobj['start'][1] + 1]
    let pos = [max([pos[0], 1]), max([pos[1], 1])]

    let winnr = s:InitWindow(bufnr, textobj)
    call cursor(pos[0], pos[1])
    call s:SetWindowAutocmds(a:tbl, a:cell_id, winnr, bufnr)

    " Fire user event for cell edit window open
    let g:TableCellEditData = {'bufnr': bufnr, 'winid': win_getid(winnr), 'table': a:tbl, 'cell_id': a:cell_id}
    if exists('#User#TableCellEditPre')
        doautocmd User TableCellEditPre
    endif
endfunction

function! table#cell_editor#EditAtCursor() abort
    let cursor = [line('.'), col('.')]
    let bufnr = bufnr('%')
    let cfg_opts = table#config#Config(bufnr).options
    let tbl = table#table#Get(cursor[0], cfg_opts.chunk_size)

    if !tbl.valid
        return
    endif

    let coord = table#cursor#GetCoord(tbl, cursor, {'type_override': 'cell'})
    let cell_id = [coord.coord[0], coord.coord[2]]

    if cell_id[1] < 0 || cell_id[1] > tbl.rows[cell_id[0]].ColCount() - 1
        return
    endif

    call s:EditCell(tbl, cell_id)
endfunction

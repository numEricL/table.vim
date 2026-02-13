let s:save_cpo = &cpo
set cpo&vim

let g:table_version = '0.1.0'

function! table#Version() abort
    return g:table_version
endfunction

function! table#Setup(config) abort
    call table#config#Setup(a:config)
endfunction

function! table#SetBufferConfig(config) abort
    call table#config#SetBufferConfig(bufnr('%'), a:config)
endfunction

function! table#RestoreDefault() abort
    call table#config#RestoreDefault(bufnr('%'))
endfunction

function! table#IsTable(linenr) abort
    let range = table#parse#FindTableRange(a:linenr)
    return range !=# [-1, -1]
endfunction

function! table#AlignIfNotEscaped() abort
    " in vim versions without <cmd> we leave insert mode in <plug>(table_align_if_not_escaped)
    let offset = (!has('nvim') && v:version < 900)? 2 : 3
    let char_before_cursor = getline('.')[col('.') - offset]
    if char_before_cursor ==# '\'
        return
    else
        call table#Align(line('.'))
    endif
endfunction

function! table#Align(linenr) abort
    let cfg_opts = table#config#Config(bufnr('%')).options
    let table = table#table#Get(a:linenr, cfg_opts.chunk_size)
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    call table#draw#CurrentlyPlaced(table)

    let table = table#table#Get(a:linenr, [0,0])
    let sep_id = (a:linenr - table.placement.bounds[0]) > 0? 0 : -1
    if coord.type ==# 'cell'
        let coord.coord[0] = 0
    elseif coord.type ==# 'alignment'
        let coord.type= 'separator'
        let coord.coord = [ sep_id, (coord.coord[0]+1)/2 ]
    elseif coord.type ==# 'separator'
        let coord.coord[0] = sep_id
    endif
    call table#cursor#SetCoord(table, coord)
endfunction

function! table#Complete(linenr) abort
    let table = s:GetFullTable(a:linenr)
    if !table.valid
        return
    endif
    call table#draw#Table(table)
endfunction

function! table#ToDefault(linenr) abort
    let table = s:GetFullTable(a:linenr)
    if !table.valid
        return
    endif
    let bufnr = table.placement.bufnr
    let cfg = table#config#Config(bufnr)
    let style = table#config#Style(bufnr)

    call table#config#SetBufferConfig(bufnr, { 'style': 'default' })
    call table#draw#Table(table)

    call table#config#SetBufferConfig(bufnr, cfg)
    call table#config#SetStyle(bufnr, style)
endfunction

function! table#ToStyle(linenr, style_name) abort
    let table = s:GetFullTable(a:linenr)
    if !table.valid
        return
    endif
    let bufnr = table.placement.bufnr

    call table#config#SetBufferConfig(bufnr, { 'style': a:style_name })
    call table#draw#Table(table)
endfunction

function! table#CycleCursor(dir, count1) abort
    let curpos = getpos('.')[1:2]
    let table = table#table#Get(curpos[0], [0,0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2], {'dir': a:dir})
    if coord.type ==# 'separator'
        let coord = table#cursor#GetCoord(table, getpos('.')[1:2], {'type_override': 'cell'})
    endif
    for _ in range(a:count1)
        let coord = s:CycleCursor(table, a:dir, coord)
        if coord.type ==# 'cell'
            let [table, coord] = s:UpdateOnCycleWrapCell(table, a:dir, coord)
        endif
    endfor
    call table#cursor#SetCoord(table, coord)
endfunction

function! table#CellEditor() abort
    if has('nvim')
        lua require('table_vim.cell_editor').edit_at_cursor()
    else
        call table#cell_editor#EditAtCursor()
    endif
endfunction

function! table#Sort(linenr, dim_kind, id, flags) abort
    let table = s:GetFullTable(a:linenr)
    if !table.valid
        return
    endif
    call table#sort#Sort(table, a:dim_kind, a:id, a:flags)
    call table#draw#CurrentlyPlaced(table)
endfunction

function! s:UpdateOnCycleWrapCell(table, dir, coord) abort
    let new_table = a:table
    let new_coord = a:coord
    if a:dir ==# 'forward' && new_coord.coord[0] == 0 && new_coord.coord[2] == 0
        let new_coord.coord[1] = 0
        let is_bottom_hunk = (a:table.placement.bounds[1] == a:table.placement.full_bounds[1])
        if !is_bottom_hunk
            let new_table = table#table#Get(a:table.placement.bounds[1] + 1, [0,0])
        else
            let new_table = table#table#Get(a:table.placement.full_bounds[0], [0,1])
        endif
    elseif a:dir ==# 'backward'
        let last_row = a:table.RowCount() - 1
        let last_col = a:table.rows[last_row].ColCount() - 1
        if new_coord.coord[0] == last_row && new_coord.coord[2] == last_col
            let new_coord.coord[1] = 0
            let is_top_hunk = (a:table.placement.bounds[0] == a:table.placement.full_bounds[0])
            if !is_top_hunk
                let new_table = table#table#Get(a:table.placement.bounds[0] - 1, [0,0])
            else
                let new_table = table#table#Get(a:table.placement.full_bounds[1], [-1,0])
            endif
        endif
    endif
    return [ new_table, new_coord ]
endfunction

function! s:GetFullTable(linenr) abort
    return table#table#Get(a:linenr, [0, -1])
endfunction

function! s:CycleCursor(table, dir, coord) abort
    let step = (a:dir ==# 'forward') ? 1 : -1
    if a:coord.type ==# 'alignment'
        let n = 2*len(a:table.col_align)
        let a:coord.coord[0] = (a:coord.coord[0] + step + n) % n
    elseif a:coord.type ==# 'cell'
        let row_bound = a:table.RowCount()
        let col_bounds = []
        for row in a:table.rows
            let bound = len(row.cells)
            let bound += (bound < a:table.ColCount()) ? 1 : 0
            call add(col_bounds, bound)
        endfor
        let old_cell_id = [ a:coord.coord[0], a:coord.coord[2] ]
        let new_cell_id = table#util#Step2D(old_cell_id, col_bounds, row_bound, {'step': step, 'least_significant': 'right'})
        let a:coord.coord[0] = new_cell_id[0]
        let a:coord.coord[1] = (old_cell_id[0] == new_cell_id[0]) ? a:coord.coord[1] : 0
        let a:coord.coord[2] = new_cell_id[1]
    elseif a:coord.type ==# 'separator'
        let row_id = (a:coord.coord[0] + 1) % a:table.RowCount()
        let col_id = (row_id == 0 )? 0 : min([a:coord.coord[1], a:table.rows[row_id].ColCount()])
        let col_id = max([0, col_id])
        call extend(a:coord, {'type': 'cell', 'coord': [ row_id, 0, col_id ] })
    else
        throw 'cannot move from type: ' .. a:coord.type
    endif
    return a:coord
endfunction

function! table#MoveCursorCell(dir, count1) abort
    let curpos = getpos('.')[1:2]
    let table = table#table#Get(curpos[0], [0,0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2], {'type_override': 'cell'})
    for _ in range(a:count1)
        let coord = s:MoveCursorCell(table, a:dir, coord)
        let [table, coord] = s:UpdateOnOutOfBounds(table, a:dir, coord)
    endfor
    call table#cursor#SetCoord(table, coord)
endfunction

function! s:MoveCursorCell(table, dir, coord) abort
    let [row_id, row_offset, col_id] = a:coord.coord
    let x_offset = a:dir ==# 'left' ? -1 : (a:dir ==# 'right' ? 1 : 0)
    let y_offset = a:dir ==# 'up' ? -1 : (a:dir ==# 'down' ? 1 : 0)
    " let coord go out of bounds so caller can update table if needed
    let new_row_id = row_id + y_offset
    let new_col_id = col_id + x_offset
    let a:coord.coord = [ new_row_id, 0, new_col_id ]
    return a:coord
endfunction

function! s:UpdateOnOutOfBounds(table, dir, coord) abort
    let new_table = a:table
    if a:dir ==# 'down' && a:coord.coord[0] == a:table.RowCount()
        let is_bottom_hunk = (a:table.placement.bounds[1] == a:table.placement.full_bounds[1])
        if !is_bottom_hunk
            let new_table = table#table#Get(a:table.placement.bounds[1] + 1, [0,0])
            let a:coord.coord[0] = 0
        else
            let a:coord.coord[0] += -1
        endif
    elseif a:dir ==# 'up' && a:coord.coord[0] == -1
        let is_top_hunk = (a:table.placement.bounds[0] == a:table.placement.full_bounds[0])
        if !is_top_hunk
            let new_table = table#table#Get(a:table.placement.bounds[0] - 1, [0,0])
        else
            let a:coord.coord[0] += 1
        endif
    elseif a:dir ==# 'right'
        let row = new_table.rows[a:coord.coord[0]]
        let col_bound = row.ColCount()
        if a:coord.coord[2] == col_bound
            let a:coord.coord[2] = col_bound - 1
        endif
    endif
    return [ new_table, a:coord ]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

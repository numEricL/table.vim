let s:save_cpo = &cpo
set cpo&vim

let g:table_version = '0.2.0'

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
    let char_before_pipe = getline('.')[col('.') - offset]
    if char_before_pipe ==# '\'
        return
    else
        let cur_pos = getpos('.')[1:2]
        let cfg_opts = table#config#Config(bufnr('%')).options
        if cfg_opts.auto_split_cell
            call s:BisectIfMultilineCell(cur_pos)
        endif
        let table = table#table#Get(cur_pos[0], cfg_opts.chunk_size)
        if !table.valid
            return
        endif
        let coord = table#cursor#GetCoord(table, cur_pos)
        if coord.type ==# 'alignment'
            let coord = table#cursor#GetCoord(table, cur_pos, {'type_override': 'separator'})
        endif
        " if char under cursor before insertion is a pipe, offset by one for correct coordinate
        let char_under_cursor = getline('.')[col('.') - 1]
        let coord.coord[-1] -= ( char_under_cursor ==# '|' )? 1 : 0
        let table = table#draw#CurrentlyPlaced(table)
        call table#cursor#SetCoord(table, coord)
    endif
endfunction

function! table#Align(linenr) abort
    let cfg_opts = table#config#Config(bufnr('%')).options
    let table = table#table#Get(a:linenr, cfg_opts.chunk_size)
    if !table.valid
        return
    endif
    call table#draw#CurrentlyPlaced(table)
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
    let table = table#table#Get(curpos[0], [-1,0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2], {'dir': a:dir})
    if coord.type ==# 'separator'
        let table = table#table#Get(curpos[0], [0,0])
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
            let new_table = table#table#Get(a:table.placement.full_bounds[0], [0,0])
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
                let new_table = table#table#Get(a:table.placement.full_bounds[1], [0,0])
            endif
            let last_col = new_table.rows[0].ColCount() - 1
            let new_coord.coord[2] = last_col
        endif
    endif
    return [ new_table, new_coord ]
endfunction

function! s:GetFullTable(linenr) abort
    return table#table#Get(a:linenr, [])
endfunction

function! s:CycleCursor(table, dir, coord) abort
    let step = (a:dir ==# 'forward') ? 1 : -1
    if a:coord.type ==# 'alignment'
        let align_id = a:table.placement.align_sep_id
        let n = 2*( len(a:table.placement.positions[align_id]['separator_pos']) - 1 )
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

function! s:BisectIfMultilineCell(cur_pos) abort
    let table = table#table#Get(a:cur_pos[0], [0,0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, a:cur_pos)
    if coord.type ==# 'cell' && table.placement.multiline && s:IsCompleteRow(table, coord.coord)
        let pipe_col_byte = a:cur_pos[1]-2
        let line_up_to_pipe = strpart(getline(a:cur_pos[0]), 0, pipe_col_byte)
        let col_display = strdisplaywidth(line_up_to_pipe)
        let [bounds, row_offset] = s:GetAdjustedBounds(table, coord.coord)
        for linenr in range(bounds[0], bounds[1])
            if linenr == bounds[0] + row_offset
                continue
            endif
            let line = getline(linenr)
            let col_byte = table#util#DisplayWidthToByteWidth(line, col_display)
            call setline(linenr, strpart(line, 0, col_byte) .. '|' .. strpart(line, col_byte))
        endfor
    endif
endfunction

function! s:IsCompleteRow(table, cell_id) abort
    let positions = a:table.placement.positions
    let row_off = a:cell_id[1]
    let row_off  += (positions[ 0].type ==# 'separator') ? 1 : 0
    let start_off = (positions[ 0].type ==# 'separator') ? 1 : 0
    let end_off   = (positions[-1].type ==# 'separator') ? 1 : 0
    let [start, end] = [ start_off, len(positions) - 1 - end_off ]
    let pipe_count = len(positions[start].separator_pos)
    let pipe_count -= (row_off == start)? 1 : 0
    for pos in range(start + 1, end)
        let next_pipe_count = len(positions[pos].separator_pos) - (row_off == pos ? 1 : 0)
        if next_pipe_count != pipe_count
            return v:false
        endif
    endfor
    return v:true
endfunction

" if the separator has enough pipes, don't add more
function! s:GetAdjustedBounds(table, cell_id) abort
    let positions = a:table.placement.positions
    let cell_count = a:table.rows[a:cell_id[0]].ColCount()
    let bounds = copy(a:table.placement.bounds)
    let row_offset = a:cell_id[1]
    if positions[0].type ==# 'separator'
        let pipe_count = len(positions[0].separator_pos)
        let bounds[0]  += (pipe_count > cell_count) ? 1 : 0
        let row_offset -= (pipe_count > cell_count) ? 1 : 0
    endif
    if positions[-1].type ==# 'separator'
        let pipe_count = len(positions[-1].separator_pos)
        let bounds[1] -= (pipe_count > cell_count) ? 1 : 0
    endif
    let row_offset += (positions[0].type ==# 'separator') ? 1 : 0
    return [ bounds, row_offset ]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

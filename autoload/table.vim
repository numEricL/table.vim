function! table#IsTable(linenr) abort
    return table#parse#IsTable(a:linenr)
endfunction

function! table#GetTable(linenr) abort
    return table#table#Get(a:linenr)
endfunction

function! table#ToDefault(linenr) abort
    let table = table#GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    let cfg = table#config#Config()
    let old_style = cfg.style

    let cfg.style = 'default'
    call table#format#Align(table)
    call table#draw#Complete(table)

    let cfg.style = old_style
    call table#cursor#SetCoord(table, coord)
endfunction

function! table#Align(linenr) abort
    let table = table#GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    if coord.type ==# 'alignment'
        let cell_col = coord.coord[0]/2
        let coord.coord[0] = 2 * (cell_col+1)
    endif
    call table#format#Align(table)
    call table#draw#Incomplete(table)
    call table#cursor#SetCoord(table, coord)
endfunction

function! table#Complete(linenr) abort
    let table = table#GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    call table#format#FillGaps(table)
    call table#format#Align(table)
    call table#draw#Complete(table)
    call table#cursor#SetCoord(table, coord)
endfunction

function! table#CycleCursorCell(dir, count1) abort
    let curpos = getpos('.')[1:2]
    let table = table#GetTable(curpos[0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    for _ in range(a:count1)
        let coord = s:CycleCursorCell(table, a:dir, coord)
    endfor
    call table#cursor#SetCoord(table, coord)
endfunction

function! s:CycleCursorCell(table, dir, coord) abort
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
        let row_offset = (old_cell_id[0] == new_cell_id[0]) ? a:coord.coord[1] : 0
        let a:coord.coord = [ new_cell_id[0], row_offset, new_cell_id[1] ]
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
    let table = table#GetTable(curpos[0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2], 'cell')
    for _ in range(a:count1)
        let coord = s:MoveCursorCell(table, a:dir, coord)
    endfor
    call table#cursor#SetCoord(table, coord)
endfunction

function! s:MoveCursorCell(table, dir, coord) abort
    let [row_id, row_offset, col_id] = a:coord.coord
    let x_offset = a:dir ==# 'left' ? -1 : (a:dir ==# 'right' ? 1 : 0)
    let y_offset = a:dir ==# 'up' ? -1 : (a:dir ==# 'down' ? 1 : 0)
    let new_row_id = row_id + y_offset
    let new_row_id = min([max([0, new_row_id]), a:table.RowCount() - 1])
    let new_col_id = col_id + x_offset
    let new_col_id = min([max([0, new_col_id]), len(a:table.rows[new_row_id].cells) - 1])
    let a:coord.coord = [ new_row_id, 0, new_col_id ]
    return a:coord
endfunction

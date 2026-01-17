function! table#IsTable(linenr) abort
    return table#parse#IsTable(a:linenr)
endfunction

function! table#GetTable(linenr) abort
    return table#table#Get(a:linenr)
endfunction

function! table#ToStyle(linenr, style) abort
    let table = table#GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    let config = copy(g:config)
    let g:config = { 'style' : a:style }
    call table#format#Align(table)
    call table#draw#Complete(table)
    let g:config = config
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

function! table#NextCell(dir, count1) abort
    let curpos = getpos('.')[1:2]
    let table = table#GetTable(curpos[0])
    if !table.valid
        return
    endif
    let coord = table#cursor#GetCoord(table, getpos('.')[1:2])
    for _ in range(a:count1)
        let coord = s:NextCell(table, a:dir, coord)
    endfor
    call table#cursor#SetCoord(table, coord)
endfunction

function! s:NextCell(table, dir, coord) abort
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

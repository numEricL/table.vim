function table#textobj#Cell() abort
    let pos = getpos('.')[1:2]
    let table = GetTable(pos[0])
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = GetCursorCoord(table, pos, 'cell')
    return TextObjBlock(table, coord.coord, coord.coord)
endfunction

function table#textobj#Row() abort
    let pos = getpos('.')[1:2]
    let table = GetTable(pos[0])
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = GetCursorCoord(table, pos, 'cell')
    let row_id = coord.coord[0]
    let col_count = table.rows[row_id].ColCount()
    let coord1 = [ row_id, 0, 0 ]
    let coord2 = [ row_id, 0, col_count - 1 ]
    return TextObjBlock(table, coord1, coord2)
endfunction

function table#textobj#Column() abort
    let pos = getpos('.')[1:2]
    let table = GetTable(pos[0])
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = GetCursorCoord(table, pos, 'cell')
    let col_id = coord.coord[2]
    let row_count = table.RowCount()
    let coord1 = [ 0, 0, col_id ]
    let coord2 = [ row_count - 1, 0, col_id ]
    return TextObjBlock(table, coord1, coord2)
endfunction

function TextObjBlock(table, coord1, coord2) abort
    " get top-left pos of coord1
    let [row_id, _, col_id] = a:coord1
    let pos_id = a:table.rows[row_id].placement_id
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let linenr = a:table.placement.row_start + pos_id
    let col = sep_pos[col_id][1] + 1
    let topleft = [linenr, col]

    " get bottom-right pos of coord2
    let [row_id, _, col_id] = a:coord2
    let pos_id = a:table.rows[row_id].placement_id + a:table.rows[row_id].Height() - 1
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let linenr = a:table.placement.row_start + pos_id
    let col = sep_pos[col_id+1][0]
    let bottomright = [linenr, col]
    return { 'valid': v:true, 'start': topleft, 'end': bottomright, 'v_mode_override': '' }
endfunction

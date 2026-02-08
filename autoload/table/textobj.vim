let s:save_cpo = &cpo
set cpo&vim

function! table#textobj#Select(GetTextObj, ...) abort
    let args = a:000
    let mode = mode(1)
    " Determine the current mode and set visual selection accordingly
    if mode =~# '\v^[vV]$'
        let v_block = [ getpos('v')[1:2], getpos('.')[1:2] ]
        let text_obj = call(a:GetTextObj, args)
        if !text_obj.valid
            return
        endif
        let [text_obj.start, text_obj.end] = s:ConvexUnion(v_block, [text_obj.start, text_obj.end])
        call s:SetVisualSelection(text_obj)
    elseif mode[0:1] ==# 'no'
        let v_mode = mode[-1:]
        let v_mode = (v_mode =~# '\v^[vV]$')? v_mode : ''
        let text_obj = call(a:GetTextObj, args)
        if !text_obj.valid
            return
        endif
        call s:SetVisualSelection(text_obj, v_mode)
    elseif v:version < 900 && mode ==# 'n'
        " compatibility for vim8 without <cmd> mappings
        normal! gv
        let v_mode = mode(1)
        let v_block = [ getpos('v')[1:2], getpos('.')[1:2] ]
        let text_obj = call(a:GetTextObj, args)
        if !text_obj.valid
            return
        endif
        let [text_obj.start, text_obj.end] = s:ConvexUnion(v_block, [text_obj.start, text_obj.end])
        call s:SetVisualSelection(text_obj)
    else
        throw 'Unsupported mode for TextObj: "' .. mode(1) .. '"'
    endif
endfunction

function! table#textobj#Cell(count1, type) abort
    let pos = getpos('.')[1:2]
    let table = table#table#Get(pos[0], [0,0])
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = table#cursor#GetCoord(table, pos, {'type_override': 'cell'})
    let row = coord.coord[0]
    let col1 = coord.coord[2]
    let col2 = col1 + a:count1 - 1
    let col2 = min([col2, table.rows[row].ColCount() - 1])
    let coord1 = [ row, 0, col1 ]
    let coord2 = [ row, 0, col2 ]
    let text_obj = s:TextObjBlock(table, coord1, table, coord2)
    let text_obj = s:AdjustForType(table, coord1, table, coord2, text_obj, 'cell', a:type)
    return text_obj
endfunction

function! table#textobj#Row(count1, type) abort
    let pos = getpos('.')[1:2]
    let table = table#table#Get(pos[0], [0,0])
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = table#cursor#GetCoord(table, pos, {'type_override': 'cell'})
    let row1 = coord.coord[0]
    let row2 = row1 + a:count1 - 1
    let row2 = min([row2, table.RowCount() - 1])
    let col2 = table.rows[row2].ColCount() - 1
    let coord1 = [ row1, 0, 0 ]
    let coord2 = [ row2, 0, col2 ]
    let text_obj = s:TextObjBlock(table, coord1, table, coord2)
    let text_obj = s:AdjustForType(table, coord1, table, coord2, text_obj, 'row', a:type)
    let text_obj.preferred_v_mode = 'V'
    return text_obj
endfunction

function! table#textobj#Column(count1, type) abort
    let pos = getpos('.')[1:2]
    let chunk_size = [ 0, 0 ]
    let table = table#table#Get(pos[0], chunk_size)
    if !table.valid
        return { 'valid': v:false }
    endif
    let coord = table#cursor#GetCoord(table, pos, {'type_override': 'cell'})
    let row = coord.coord[0]
    let col1 = coord.coord[2]
    let col2 = col1 + a:count1 - 1
    let col2 = min([col2, table.rows[row].ColCount() - 1])

    let table1 = table#table#Get(table.placement.full_bounds[0], chunk_size)
    let coord1 = [ 0, 0, col1 ]

    let table2 = table#table#Get(table.placement.full_bounds[1], chunk_size)
    let coord2 = [ table2.RowCount() - 1, 0, col2 ]

    let text_obj = s:TextObjBlock(table1, coord1, table2, coord2)
    let text_obj = s:AdjustForType(table1, coord1, table2, coord2, text_obj, 'column', a:type)
    return text_obj
endfunction

" finds inner cell
function! s:TextObjBlock(table1, coord1, table2, coord2) abort
    " get top-left pos of coord1
    let [row_id, _, col_id] = a:coord1
    let pos_id = a:table1.rows[row_id].placement_id
    let sep_pos = a:table1.placement.positions[pos_id]['separator_pos']
    let linenr = a:table1.placement.bounds[0] + pos_id
    let col = sep_pos[col_id][1] + 1
    let topleft = [linenr, col]

    " get bottom-right pos of coord2
    let [row_id, _, col_id] = a:coord2
    let pos_id = a:table2.rows[row_id].placement_id + a:table2.rows[row_id].Height() - 1
    let sep_pos = a:table2.placement.positions[pos_id]['separator_pos']
    let linenr = a:table2.placement.bounds[0] + pos_id
    let col = sep_pos[col_id+1][0]
    let bottomright = [linenr, col]
    let text_obj = {
                \ 'valid': v:true,
                \ 'start': topleft,
                \ 'end': bottomright,
                \ 'preferred_v_mode': '',
                \ }
    return text_obj
endfunction

function! s:AdjustForType(table1, coord1, table2, coord2, text_obj, text_obj_type, type) abort
    "check placement for top border
    let row_id = a:coord1[0]
    let pos_id = a:table1.rows[row_id].placement_id
    let pos_id = max([0, pos_id - 1])
    let line_type = a:table1.placement.positions[pos_id]['type']
    let has_top_border = (line_type =~# '\v^(separator|top|alignment|bottom)$')

    "check placement for bottom border
    let row_id = a:coord2[0]
    let pos_id = a:table2.rows[row_id].placement_id + a:table2.rows[row_id].Height() - 1
    let pos_id = min([pos_id + 1, len(a:table2.placement.positions) - 1])
    let line_type = a:table2.placement.positions[pos_id]['type']
    let has_bottom_border = (line_type =~# '\v^(separator|top|alignment|bottom)$')

    let bufnr = a:table2.placement.bufnr
    let style_opts = table#config#Style(bufnr).options
    "check placement for left border
    let col_id = a:coord1[2]
    let has_left_border = (col_id > 0) ? v:true : !style_opts.omit_left_border

    "check placement for right border
    let col_id = a:coord2[2]
    let has_right_border = (col_id < a:table2.rows[0].ColCount() - 1) ? v:true : !style_opts.omit_right_border

    let top_offset = has_top_border       ? 1 : 0
    let left_offset = has_left_border     ? 1 : 0
    let bottom_offset = has_bottom_border ? 1 : 0
    let right_offset = has_right_border   ? 1 : 0

    if a:type ==# 'around'
        let a:text_obj.start = [ a:text_obj.start[0] - top_offset, a:text_obj.start[1] - left_offset ]
        let a:text_obj.end = [ a:text_obj.end[0] + bottom_offset, a:text_obj.end[1] + right_offset ]
    elseif a:type ==# 'default'
        if a:text_obj_type ==# 'cell'
            let a:text_obj.start = [ a:text_obj.start[0], a:text_obj.start[1]]
            let a:text_obj.end = [ a:text_obj.end[0] + bottom_offset, a:text_obj.end[1] + right_offset ]
        elseif a:text_obj_type ==# 'row'
            let a:text_obj.start = [ a:text_obj.start[0], a:text_obj.start[1] - left_offset ]
            let a:text_obj.end = [ a:text_obj.end[0] + bottom_offset, a:text_obj.end[1] + right_offset ]
        elseif a:text_obj_type ==# 'column'
            let a:text_obj.start = [ a:text_obj.start[0] - top_offset, a:text_obj.start[1] ]
            let a:text_obj.end = [ a:text_obj.end[0] + bottom_offset, a:text_obj.end[1] + right_offset ]
        endif
    endif
    return a:text_obj
endfunction

function! s:ConvexUnion(block1, block2) abort
    let block1 = s:OrderBlock(a:block1)
    let block2 = s:OrderBlock(a:block2)
    let p1 = [ min([block1[0][0], block2[0][0]]), min([block1[0][1], block2[0][1]]) ]
    let p2 = [ max([block1[1][0], block2[1][0]]), max([block1[1][1], block2[1][1]]) ]
    return [p1, p2]
endfunction

function! s:OrderBlock(block) abort
    let [p1, p2] = a:block
    if p1[0] < p2[0] || (p1[0] == p2[0] && p1[1] <= p2[1])
        return [p1, p2]
    else
        return [p2, p1]
    endif
endfunction

function! s:SetVisualSelection(text_obj, ...) abort
    if a:text_obj['valid']
        let v_mode = a:0? a:1 : ''
        let v_mode = empty(v_mode)? get(a:text_obj, 'preferred_v_mode', 'v') : v_mode
        call cursor(a:text_obj['start'])
        execute "normal! \<esc>" .. v_mode
        call cursor(a:text_obj['end'])
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

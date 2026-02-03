" coord: { 'type': 'cell'|'alignment'|'separator'|'invalid', 'coord': [...] }
"   type cell: coord: [ row_id, row_offset, col_id ]
"   type alignment: coord: [ col_id ]
"   type separator: coord: [ row_id, col_id ]
function! table#cursor#GetCoord(table, pos, ...) abort
    let opts = a:0 ? a:1 : {}
    let type_override = get(opts, 'type_override', '')
    if !a:table.valid
        return {'type': 'invalid', 'coord': []}
    endif
    let coord = { 'type': s:GetType(a:table, a:pos[0]), 'coord': [] }

    let placement_id = a:pos[0] - a:table.placement.bounds[0]
    if placement_id < 0 || placement_id >= len(a:table.placement.positions)
        return {'type': 'invalid', 'coord': []}
    endif

    let row_id     = a:table.placement.positions[placement_id]['row_id']
    let row_offset = a:table.placement.positions[placement_id]['row_offset']
    let sep_pos    = a:table.placement.positions[placement_id]['separator_pos']

    if !empty(type_override)
        if type_override !=# 'cell'
            throw 'only cell type override is supported'
        endif
        if coord.type =~# '\v^separator|alignment$'
            let coord.type = 'cell'
            let row_id += 1
            let row_id = min([row_id, a:table.RowCount() - 1])
            let row_offset = 0
        endif
    endif

    if coord.type ==# 'cell'
        let row = max([0, row_id])
        let offset = max([0, row_offset])
        let boundaries = map(copy(sep_pos), 'v:val[0] + 1')
        let col = table#util#SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ row, offset, col ]
    elseif coord.type ==# 'alignment'
        let dir = get(opts, 'dir', 'forward')
        let boundaries = []
        for j in range(len(sep_pos)-1)
            if dir ==# 'forward'
                call add(boundaries, sep_pos[j][1] + 1)
                call add(boundaries, sep_pos[j+1][0] - 1)
            else
                call add(boundaries, sep_pos[j][1] + 1)
                call add(boundaries, sep_pos[j][1] + 2)
            endif
        endfor
        let col = table#util#SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ col ]
    elseif coord.type ==# 'separator'
        let boundaries = map(copy(sep_pos), 'v:val[0] + 1')
        let col = table#util#SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ row_id, col ]
    else
        throw 'unsupported cursor type: ' .. coord.type
    endif
    return coord
endfunction

function! table#cursor#SetCoord(table, coord) abort
    if !a:table.valid
        return
    endif
    if a:coord.type ==# 'cell'
        call s:SetCursorCell(a:table, a:coord.coord)
    elseif a:coord.type ==# 'alignment'
        call s:SetCursorAlignmentSeparator(a:table, a:coord.coord[0])
    elseif a:coord.type ==# 'separator'
        call s:SetCursorSeparator(a:table, a:coord.coord)
    else
        throw 'unsupported cursor type: ' .. a:coord.type
    endif
endfunction

function! s:GetType(table, linenr) abort
    if !a:table.valid
        return ''
    endif
    let placement_id = a:linenr - a:table.placement.bounds[0]
    if placement_id < 0 || placement_id >= len(a:table.placement.positions)
        return ''
    endif
    let type = a:table.placement.positions[placement_id]['type']
    if type =~# '\v^(row|incomplete)$'
        return 'cell'
    elseif type ==# 'alignment'
        return 'alignment'
    elseif type =~# '\v^(top|bottom|separator|incomplete)$'
        return 'separator'
    else
        throw 'unknown line type: ' .. type
    endif
endfunction

function! s:SetCursorCell(table, cell_id) abort
    let [row_id, row_offset, col_id] = a:cell_id
    let pos_id = a:table.rows[row_id].placement_id + row_offset

    let linenr = a:table.placement.bounds[0] + pos_id
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let col = 0

    let row_cells = a:table.rows[row_id].cells
    if col_id < 0 || col_id > len(row_cells)
        return
    elseif col_id == len(row_cells)
        let col = sep_pos[-1][1] + 1
    else
        let cfg_opts = table#config#Config().options
        if cfg_opts.multiline && col_id >= len(sep_pos)
            let col = s:FindMultiCellSepCol(a:table, a:cell_id)
        else
            let col = sep_pos[col_id][1]
            let matchpos = matchstrpos(row_cells[col_id][row_offset], '\m\S')
            if matchpos[1] != -1
                let col += matchpos[1] + 1
            else
                let col += 2
            endif
        endif
    endif
    call cursor(linenr, col)
endfunction

function! s:FindMultiCellSepCol(table, cell_id) abort
    let [row_id, _, col_id] = a:cell_id

    let pos_id_start = a:table.rows[row_id].placement_id
    let pos_id_end = pos_id_start + a:table.rows[row_id].Height()

    for pos_id in range(pos_id_start, pos_id_end)
        let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
        if len(sep_pos) > col_id
            return sep_pos[col_id][1]
        endif
    endfor
    throw 'separator not found'
endfunction

function! s:SetCursorAlignmentSeparator(table, col_id) abort
    let id = a:table.placement.align_id

    let linenr = a:table.placement.bounds[0] + id
    let sep_pos = a:table.placement.positions[id]['separator_pos']
    let col = 0

    if id == -1 || a:col_id < 0 || a:col_id > 2 * len(a:table.col_align)
        return
    elseif a:col_id == 2 * len(a:table.col_align)
        let col = sep_pos[-1][1] + 1
    else
        let sep_id = (a:col_id+1) / 2
        let even = (a:col_id % 2) == 0
        let col = even? sep_pos[sep_id][1]+1 : sep_pos[sep_id][0]
    endif
    call cursor(linenr, col)
endfunction

function! s:SetCursorSeparator(table, sep_id) abort
    let [row_id, col_id] = a:sep_id
    let pos_id = 0
    if row_id >= 0
        let row = a:table.rows[row_id]
        let pos_id = row.placement_id + row.Height()
    endif

    let linenr = a:table.placement.bounds[0] + pos_id
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let col = 0

    if col_id < 0 || col_id >= len(sep_pos)
        return
    else
        let col = sep_pos[col_id][1]
    endif
    call cursor(linenr, col)
endfunction

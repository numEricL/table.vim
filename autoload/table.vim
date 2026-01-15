" let g:config = { 'style' : 'single_full' }

if !exists('g:config')
    let g:config = { 'style' : 'markdown' }
endif

let g:t = { 'valid': v:false }
let g:i_separator = '|'
let g:i_dash = '-'
let g:default_alignment = 'l'
" let g:multiline_cells_enable = v:false
let g:multiline_cells_enable = v:true
let g:multiline_cells_presever_indentation = v:false
" let g:multiline_cells_presever_indentation = v:true

function Style() abort
    return table#style#Get(g:config.style)
endfunction

function table#ToStyle(linenr, style) abort
    let table = GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = GetCursorCoord(table, getpos('.')[1:2])
    let config = copy(g:config)
    let g:config = { 'style' : a:style }
    call AlignCells(table)
    call DrawComplete(table)
    let g:config = config
    call SetCursorCoord(table, coord)
endfunction

" let custom = {
"             \ 'box_drawing'          : box_drawing#Get('double'),
"             \ 'omit_left_border'     : v:true,
"             \ 'omit_right_border'    : v:true,
"             \ 'omit_top_border'      : v:true,
"             \ 'omit_bottom_border'   : v:true,
"             \ 'omit_separator_rows'  : v:true,
"             \ }

function table#IsTable(linenr) abort
    let line = getline(a:linenr)
    let prev = getline(a:linenr-1)
    let next = getline(a:linenr+1)

    if IsTableLine(line)
        if IsTableLine(prev) || IsIncompleteTableLine(prev)
            return v:true
        elseif IsTableLine(next) || IsIncompleteTableLine(next)
            return v:true
        endif
    elseif IsIncompleteTableLine(line)
        if IsTableLine(prev) || IsTableLine(next)
            return v:true
        endif
    endif
    return v:false
endfunction

function table#Align(linenr) abort
    let table = GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = GetCursorCoord(table, getpos('.')[1:2])
    if coord.type ==# 'alignment'
        let cell_col = coord.coord[0]/2
        let coord.coord[0] = 2 * (cell_col+1)
    endif
    call AlignCells(table)
    call DrawIncomplete(table)
    call SetCursorCoord(table, coord)
endfunction

" should fill col_align if missing
function table#Complete(linenr) abort
    let table = GetTable(a:linenr)
    if !table.valid
        return
    endif
    let coord = GetCursorCoord(table, getpos('.')[1:2])
    call FillGapCells(table)
    call AlignCells(table)
    call DrawComplete(table)
    call SetCursorCoord(table, coord)
endfunction

function table#NextCell(dir) abort
    let curpos = getpos('.')[1:2]
    let table = GetTable(curpos[0])
    if !table.valid
        return
    endif
    let coord = GetCursorCoord(table, getpos('.')[1:2])

    let step = (a:dir ==# 'forward') ? 1 : -1
    if coord.type ==# 'alignment'
        let n = 2*len(table.col_align)
        let coord.coord[0] = (coord.coord[0] + step + n) % n
    elseif coord.type ==# 'cell'
        let row_bound = table.RowCount()
        let col_bounds = []
        for row in table.rows
            let bound = len(row.cells)
            let bound += (bound < table.ColCount()) ? 1 : 0
            call add(col_bounds, bound)
        endfor
        let old_cell_id = [ coord.coord[0], coord.coord[2] ]
        let new_cell_id = Step2D(old_cell_id, col_bounds, row_bound, {'step': step, 'least_significant': 'right'})
        let row_offset = (old_cell_id[0] == new_cell_id[0]) ? coord.coord[1] : 0
        let coord.coord = [ new_cell_id[0], row_offset, new_cell_id[1] ]
    elseif coord.type ==# 'separator'
        let row_id = (coord.coord[0] + 1) % table.RowCount()
        let col_id = (row_id == 0 )? 0 : min([coord.coord[1], table.rows[row_id].ColCount()])
        let col_id = max([0, col_id])
        let coord = {'type': 'cell', 'coord': [ row_id, 0, col_id ] }
    else
        throw 'cannot move from type: ' .. coord.type
    endif
    call SetCursorCoord(table, coord)
endfunction

" alignment separator might return as 'row' or 'separator', check with SplitPos
function LineType(cells, separators) abort
    let type = 'row'

    " check if separator
    let horiz = GeneralHorizPattern()
    let is_sep = v:true
    let is_align = v:false
    let beg_pat = '\V\^\s\*'
    let end_pat = '\s\*\$'
    for cell in a:cells
        let is_sep_cell = (cell =~# beg_pat .. ':\?' .. horiz .. '\+:\?' .. end_pat) || (cell =~# '\v^\s*::?\s*$')
        let is_sep = is_sep && is_sep_cell
        let is_align = is_align || cell =~# ':'
    endfor

    if is_sep
        let type = (is_align)? 'alignment' : 'separator'
    endif
    return type
endfunction

function ParseLine(linenr) abort
    let line = getline(a:linenr)
    let [cells, sep_pos, seps] = SplitPos(line)
    let type = ''
    if !empty(cells)
        let type = LineType(cells, seps)
    else
        let [ sep_pos, type ] = ParseIncomplete(line, seps, sep_pos)
    endif
    let col_start = strdisplaywidth(strpart(line, 0, sep_pos[0][1]))
    return [ cells, col_start, sep_pos, type ]
endfunction

function ParseIncomplete(line, seps, sep_pos) abort
    let horiz = GeneralHorizPattern()
    let type = ''
    if empty(a:seps)
        let match = matchstrpos(a:line, '\V' .. horiz .. '\+')
        call add(a:sep_pos, match[1:2])
        let type = 'separator'
    else
        let match = matchstrpos(a:line, '\V\^' .. horiz .. '\+', a:sep_pos[0][1])
        if match[1] != -1
            call add(a:sep_pos, match[1:2])
            let type = 'separator'
        else
            let type = 'incomplete'
        endif
    endif
    return [ a:sep_pos, type ]
endfunction

"TODO: just use general separator pattern instead of looping over types
function IsTableLine(line) abort
    let cs = split(&commentstring, '%s')
    let cs_pattern = escape(trim(get(cs, 0, '')), '\')
    let cs_pattern = '\s\*\(' ..cs_pattern .. '\)\?\s\*'
    let is_table = v:false
    for type in [ 'row', 'separator', 'alignment','top', 'bottom' ]
        let [ left, right, sep, horiz ] = BoxDrawingPatterns(type)
        if !empty(left) && !empty(right)
            if a:line =~# '\V\^' .. cs_pattern .. left .. '\.\*' .. right
                let is_table = v:true
                break
            endif
        else
            if a:line =~# '\V\^' .. cs_pattern .. left .. '\.\*' .. sep .. '\.\*' .. right
                let is_table = v:true
                break
            endif
        endif
        if type == 'alignment' || type == 'separator'
            if a:line =~# '\V\^' .. cs_pattern .. horiz .. '\+\s\*\$'
                let is_table = v:true
                break
            endif
        endif
    endfor
    return is_table
endfunction

function IsIncompleteTableLine(line) abort
    let cs = split(&commentstring, '%s')
    let cs_pattern = escape(trim(get(cs, 0, '')), '\')
    let cs_pattern = '\s\*\(' ..cs_pattern .. '\)\?\s\*'
    for type in [ 'row', 'separator', 'top', 'bottom', 'alignment' ]
        let [ left, right, sep, horiz ] = GetBoxDrawingChars(type)
        if !empty(left) && (a:line =~# '\V\^' .. cs_pattern .. left)
            return v:true
        endif
        if !empty(sep) && (a:line =~# '\V\^' .. cs_pattern .. sep)
            return v:true
        endif
        if (a:line =~# '\V\^' .. cs_pattern .. g:i_separator)
            return v:true
        endif
    endfor
    return v:false
endfunction

function GetBoxDrawingChars(type) abort
    if a:type == 'top'
        let left  = Style().box_drawing.top_left
        let right = Style().box_drawing.top_right
        let sep   = Style().box_drawing.top_sep
        let horiz = Style().box_drawing.top_horiz
    elseif a:type == 'bottom'
        let left  = Style().box_drawing.bottom_left
        let right = Style().box_drawing.bottom_right
        let sep   = Style().box_drawing.bottom_sep
        let horiz = Style().box_drawing.bottom_horiz
    elseif a:type == 'alignment'
        let left  = Style().box_drawing.align_left
        let right = Style().box_drawing.align_right
        let sep   = Style().box_drawing.align_sep
        let horiz = Style().box_drawing.align_horiz
    elseif a:type == 'separator'
        let left  = Style().box_drawing.sep_left
        let right = Style().box_drawing.sep_right
        let sep   = Style().box_drawing.sep_sep
        let horiz = Style().box_drawing.sep_horiz
    elseif a:type == 'row'
        let left  = Style().box_drawing.row_left
        let right = Style().box_drawing.row_right
        let sep   = Style().box_drawing.row_sep
        let horiz = ''
    else
        throw 'unknown separator type: ' .. a:type
    endif
    let left = Style().omit_left_border ? '' : left
    let right = Style().omit_right_border ? '' : right
    return [left, right, sep, horiz]
endfunction

function AnyPattern(list) abort
    let unique = uniq(sort(a:list))
    call filter(unique, '!empty(v:val)')
    if len(unique) == 1
        return escape(unique[0], '\')
    endif
    " let pattern = '\%(' .. escape(unique[0], '\')
    let pattern = '\%(' .. unique[0]
    if len(unique) > 1
        for i in range(1, len(unique)-1)
            " let pattern ..= '\|' .. escape(unique[i], '\')
            let pattern ..= '\|' .. unique[i]
        endfor
    endif
    let pattern ..= '\)'
    return pattern
endfunction

function GeneralSeparatorPattern() abort
    let separators = [
                \ Style().box_drawing.top_left,
                \ Style().box_drawing.top_right,
                \ Style().box_drawing.top_sep,
                \ Style().box_drawing.bottom_left,
                \ Style().box_drawing.bottom_right,
                \ Style().box_drawing.bottom_sep,
                \ Style().box_drawing.align_left,
                \ Style().box_drawing.align_right,
                \ Style().box_drawing.align_sep,
                \ Style().box_drawing.sep_left,
                \ Style().box_drawing.sep_right,
                \ Style().box_drawing.sep_sep,
                \ Style().box_drawing.row_left,
                \ Style().box_drawing.row_right,
                \ Style().box_drawing.row_sep,
                \ g:i_separator,
                \ ]
    return AnyPattern(separators)
endfunction

function GeneralHorizPattern() abort
    let horizs = [
                \ Style().box_drawing.top_horiz,
                \ Style().box_drawing.bottom_horiz,
                \ Style().box_drawing.align_horiz,
                \ Style().box_drawing.sep_horiz,
                \ g:i_dash,
                \ ]
    return AnyPattern(horizs)
endfunction

function BoxDrawingPatterns(type) abort
    let sep = GetBoxDrawingChars(a:type)
    for i in range(3)
        let sep[i] = AnyPattern([sep[i], g:i_separator])
    endfor
    if a:type ==# 'alignment'
        let sep[3] = AnyPattern([sep[i], g:i_dash, ':'])
    else
        let sep[3] = AnyPattern([sep[i], g:i_dash])
    endif
    return sep
endfunction

function TableRowCount() dict abort
    return len(self.rows)
endfunction

function TableColCount() dict abort
    return self.max_col_count
endfunction

function TableColAlign(col) dict abort
    let align = get(self.col_align, a:col, g:default_alignment)
    return empty(align)? g:default_alignment : align
endfunction

function CellColCount() dict abort
    return len(self.cells)
endfunction

function CellRowHeight() dict abort
    return len(self.cells[0])
endfunction

function CellStrDisplayWidth(cell) abort
    let width = 0
    for line in a:cell
        let width = max([width, strdisplaywidth(line)])
    endfor
    return width
endfunction

function GetTable(linenr) abort
    let bounds = FindTableRange(a:linenr)
    if bounds[0] == -1
        return {'valid': v:false}
    endif
    " positions a list of elements, each of the form [col_start, col_end, row_id, type]
    let placement = {
                \ 'row_start'     : bounds[0],
                \ 'positions'     : [],
                \ 'align_id'      : -1,
                \ 'max_col_start' : 0,
                \ }
    " rows defines [ {'cells': [], 'type': '', 'placement_id': int} ]
    let table = {
                \ 'valid'         : v:true,
                \ 'placement'     : placement,
                \ 'rows'          : [],
                \ 'col_align'     : [],
                \ 'col_widths'    : [],
                \ 'RowCount'      : function('TableRowCount'),
                \ 'ColCount'      : function('TableColCount'),
                \ 'ColAlign'      : function('TableColAlign'),
                \ 'max_col_count' : 0,
                \ }

    let last_type = 'separator'
    for pos_id in range(bounds[1] - bounds[0] + 1)
        let [line_cells, col_start, sep_pos, type] = ParseLine(bounds[0] + pos_id)
        if type ==# 'separator'
            if pos_id == 0
                let type = 'top'
            elseif pos_id == (bounds[1] - bounds[0])
                let type = 'bottom'
            elseif table.RowCount() == 1 && placement.align_id == -1
                let type = 'alignment'
            endif
        endif

        if type =~# '\v^row|incomplete$'
            call TableAppendRow(table, type, last_type, line_cells, pos_id)
            let table.max_col_count = max([table.max_col_count, len(line_cells)])
        endif
        let last_type = type

        "types: row | separator | alignment | top | bottom | incomplete
        call add(placement.positions, {
                    \ 'row_id'        : (table.RowCount() == 0)? -1 : table.RowCount() - 1,
                    \ 'row_offset'    : (table.RowCount() == 0)? -1 : table.rows[-1].Height() - 1,
                    \ 'type'          : type,
                    \ 'separator_pos' : sep_pos,
                    \ } )
        let placement.max_col_start = max([placement.max_col_start, col_start])

        if type ==# 'alignment'
            let placement.align_id = pos_id
            for cell in line_cells
                call add(table.col_align, SeparatorAlignment(cell))
            endfor
            let table.max_col_count = max([table.max_col_count, len(line_cells)])
        endif
    endfor
    let table.col_widths = ComputeWidths(table)
    let g:t = table
    return table
endfunction

function RefineType( pos_id, row_id, align_id, type) abort
    if a:type ==# 'separator' && row_id == 0  && placement.align_id == -1
        return 'alignment'
    elseif a:type ==# 'separator' && pos_id == 0
        return 'top'
    elseif a:type ==# 'separator' && pos_id == len(placement.positions) - 1
        return 'bottom'
    endif
endfunction

function TableAppendRow(table, line_type, last_type, line_cells, pos_id) abort
    if !g:multiline_cells_enable ||  a:last_type =~# '\v' .. 'separator|alignment|top|bottom'
        " cells is a list of strings, each referring to a line in within the cell
        let cells = empty(a:line_cells)? [['']] : map(copy(a:line_cells), '[v:val]')
        let row = {
                    \ 'cells'         : cells,
                    \ 'types'         : [ a:line_type ],
                    \ 'placement_id'  : a:pos_id,
                    \ 'Height'        : function('CellRowHeight'),
                    \ 'ColCount'      : function('CellColCount'),
                    \ }
        call add(a:table.rows, row)
    else
        let row = a:table.rows[-1]
        while len(row.cells) < len(a:line_cells)
            call add(row.cells, repeat([''], row.Height()))
        endwhile
        for j in range(len(row.cells))
            call add(row.cells[j], get(a:line_cells, j, ''))
        endfor
        call add(row.types, a:line_type)
    endif
endfunction

function AppendConditionalCommentLine(linenr) abort
    let cs = split(&commentstring, '%s')
    let line = getline(a:linenr)
    let found = v:false
    let match = []
    if len(cs) > 0
        let match = matchstrpos(line, '\V\^ \*' .. escape(cs[0], '\'))
        let found = match[1] != -1
    endif
    let new_line = found? cs[0] : ''
    call append(a:linenr, new_line)
endfunction

" DrawLine does not update placement
function DrawLine(placement, pos_id, line) abort
    if a:pos_id > len(a:placement.positions)
        throw 'pos_id out of range'
    endif
    if empty(a:line)
        return a:pos_id
    endif
    let [col_start, col_end] = [-1, -1]
    if a:pos_id == len(a:placement.positions)
        let linenr = a:placement.row_start + len(a:placement.positions) - 1
        call AppendConditionalCommentLine(linenr)
        let [col_start, col_end] = [a:placement.max_col_start, a:placement.max_col_start]
        call add(a:placement.positions, {})
    else
        let col_start = a:placement.positions[a:pos_id]['separator_pos'][0][0]
        let col_end   = a:placement.positions[a:pos_id]['separator_pos'][-1][1]
    endif

    let linenr = a:placement.row_start + a:pos_id
    let current_line = getline(linenr)
    let newline = strpart(current_line, 0, col_start)
    let newline ..= repeat(' ', a:placement.max_col_start-1 - strdisplaywidth(newline))
    let newline ..= a:line
    let newline ..= strpart(current_line, col_end)
    if newline !=# current_line
        call setline(linenr, newline)
    endif
    return a:pos_id + 1
endfunction

function DrawRow(table, pos_id, row_id, ...) abort
    let fill_cell_multirows = get(a:000, 0, v:true)
    let row = a:table.rows[a:row_id]
    let pos_id = a:pos_id
    for i in range(row.Height())
        let fill_cell = fill_cell_multirows || HasRightMostSeparator(a:table, a:row_id, i)
        let rowline = ''

        if row.types[i] ==# 'incomplete'
            let rowline = g:i_separator
        else
            let single_row_cells = []
            for cell in row.cells
                call add(single_row_cells, get(cell, i, ''))
            endfor
            let left  = Style().omit_left_border  ? '' : Style().box_drawing.row_left
            let right = Style().omit_right_border ? '' : Style().box_drawing.row_right
            let sep = Style().box_drawing.row_sep
            if fill_cell
                let rowline = left .. join(single_row_cells, sep) .. right
            else
                let num_cols = NumSubRowCols(a:table, a:row_id, i)
                let rowline = left .. join(single_row_cells[0:num_cols-1], sep) .. sep
            endif
        endif
        if i == 0
            let row.placement_id = pos_id
        endif
        let pos_id = DrawLine(a:table.placement, pos_id, rowline)
    endfor
    return pos_id
endfunction

function HasRightMostSeparator(table, row_id, row_offset) abort
    let pos_id = a:table.rows[a:row_id].placement_id + a:row_offset
    return len(a:table.placement.positions[pos_id]['separator_pos']) > a:table.rows[a:row_id].ColCount()
endfunction

function NumSubRowCols(table, row_id, row_offset) abort
    let pos_id = a:table.rows[a:row_id].placement_id + a:row_offset
    return len(a:table.placement.positions[pos_id]['separator_pos']) - 1
endfunction

" type: alignment | top | bottom | separator
function DrawSeparator(table, pos_id, type, num_cols) abort
    let sep = MakeSeparator(a:table, a:type, a:num_cols)
    let pos_id = DrawLine(a:table.placement, a:pos_id, sep)
    return pos_id
endfunction

function DrawIncomplete(table) abort
    let pos_id = 0
    let new_id = 0
    while pos_id < len(a:table.placement.positions)
        let line_type = a:table.placement.positions[pos_id].type
        if line_type =~# '\v^top|bottom|separator|alignment$'
            let linenr = a:table.placement.row_start + pos_id
            let num_cols = len(SplitPos(getline(linenr))[0])
            let num_cols = (num_cols == 0)? a:table.ColCount() : num_cols
            let new_id = DrawSeparator(a:table, new_id, line_type, num_cols)
        elseif line_type =~# '\v^row|incomplete$'
            let row_id = a:table.placement.positions[pos_id].row_id
            let new_id = DrawRow(a:table, new_id, row_id, v:false)
            let pos_id += a:table.rows[row_id].Height() - 1
        else
            throw 'unknown line type: ' .. line_type
        endif
        let pos_id += 1
    endwhile
    call ClearRemaining(a:table.placement, len(a:table.placement.positions))
    call extend(a:table, GetTable(a:table.placement.row_start))
endfunction

function DrawComplete(table) abort
    let row_count = a:table.RowCount()
    if row_count == 0
        return
    endif
    let pos_id = 0

    if !Style().omit_top_border
        let num_cols = a:table.rows[0].ColCount()
        let pos_id = DrawSeparator(a:table, pos_id, 'top', num_cols)
    endif
    let pos_id = DrawRow(a:table, pos_id, 0)

    if a:table.RowCount() > 1
        let row_id = 0
        let num_cols = max([len(a:table.col_align), a:table.rows[row_id].ColCount(), a:table.rows[row_id+1].ColCount()])
        let num_cols = (num_cols == 0)? a:table.ColCount() : num_cols
        let pos_id = DrawSeparator(a:table, pos_id, 'alignment', num_cols)
        " let a:table.placement.align_id = pos_id - 1
    endif

    if a:table.RowCount() > 2
        for row_id in range(1, a:table.RowCount() - 2)
            let pos_id = DrawRow(a:table, pos_id, row_id)
            if !Style().omit_separator_rows
                let num_cols = max([a:table.rows[row_id].ColCount(), a:table.rows[row_id+1].ColCount()])
                let pos_id = DrawSeparator(a:table, pos_id, 'separator', num_cols)
            endif
        endfor
    endif

    if a:table.RowCount() > 1
        let pos_id = DrawRow(a:table, pos_id, a:table.RowCount() - 1)
    endif

    if !Style().omit_bottom_border
        let num_cols = a:table.rows[-1].ColCount()
        let pos_id = DrawSeparator(a:table, pos_id, 'bottom', num_cols)
    endif
    call ClearRemaining(a:table.placement, pos_id)
    call extend(a:table, GetTable(a:table.placement.row_start))
endfunction

function ClearRemaining(placement, pos_id) abort
    let cs = split(&commentstring, '%s')
    call map(cs, 'trim(v:val)')
    let pattern = AnyPattern(cs + ['\s'])

    for id in reverse(range(a:pos_id, len(a:placement.positions)-1))
        let linenr = a:placement.row_start + id
        let line = getline(linenr)
        let newline = strpart(line, 0, a:placement.max_col_start - 1)
        let newline ..= strpart(line, a:placement.positions[id]['separator_pos'][-1][1])
        if newline =~# '\V\^' .. pattern .. '\*\$'
            call deletebufline('%', linenr)
        else
            call setline(linenr, newline)
        endif
    endfor
endfunction

function FillGapCells(table) abort
    for row in a:table.rows
        for i in range(row.Height())
            let row.types[i] = 'row'
        endfor
        while len(row.cells) < a:table.ColCount()
            call add(row.cells, repeat([''], row.Height()))
        endwhile
    endfor
endfunction

function PadAlignLine(line, align, width) abort
    let pad_size = a:width - strdisplaywidth(a:line)
    let line = a:line
    if a:align ==# 'l'
        let line = ' ' .. line .. repeat(' ', pad_size) .. ' '
    elseif a:align ==# 'r'
        let line = ' ' .. repeat(' ', pad_size) .. line .. ' '
    elseif a:align ==# 'c'
        let left_pad = float2nr(floor(pad_size / 2))
        let right_pad = pad_size - left_pad
        let line = ' ' .. repeat(' ', left_pad) .. line .. repeat(' ', right_pad) .. ' '
    else
        throw 'unknown alignment: ' .. a:align .. ' (should be l, r, or c)'
    endif
    return line
endfunction

function AlignCells(table) abort
    call TrimCells(a:table)
    let widths = a:table.col_widths
    for row in a:table.rows
        for j in range(len(row.cells))
            let cell = row.cells[j]
            let align = a:table.ColAlign(j)
            let width = widths[j]
            for i in range(row.Height())
                let cell[i] = PadAlignLine(cell[i], align, width)
            endfor
        endfor
    endfor
endfunction

" type: alignment | top | bottom | separator
function MakeSeparator(table, type, num_cols) abort
    let [ left, right, sep, horiz ] = GetBoxDrawingChars(a:type)
    if a:num_cols == 0
        return ''
    endif
    let line = left
    let show_alignment = (a:type ==# 'alignment')
    for i in range(a:num_cols-1)
        let col_align = a:table.ColAlign(i)
        let pad_left  = (show_alignment && col_align =~# '\v^l|c$') ? ':' : horiz
        let pad_right = (show_alignment && col_align =~# '\v^r|c$') ? ':' : horiz
        let width = get(a:table.col_widths, i, 2)
        let line ..= pad_left .. repeat(horiz, width) .. pad_right .. sep
    endfor
    let i = a:num_cols - 1
    let col_align = a:table.ColAlign(i)
    let pad_left  = (show_alignment && col_align =~# '\v^l|c$') ? ':' : horiz
    let pad_right = (show_alignment && col_align =~# '\v^r|c$') ? ':' : horiz
    let width = get(a:table.col_widths, i, 2)
    let line ..= pad_left .. repeat(horiz, width) .. pad_right .. right
    return line
endfunction

" a version of split that includes positions in the result
" sep_pos_list is the list of positions one after where the separators were found
function SplitPos(line) abort
    let pattern = GeneralSeparatorPattern()
    let match_list = []
    let sep_list = []
    let sep_pos_list = []
    let match1 = matchstrpos(a:line, pattern)
    if match1[1] != -1
        call add(sep_list, match1[0])
        call add(sep_pos_list, [match1[1], match1[2]])
        let match2 = matchstrpos(a:line, pattern, match1[2])
        while match2[1] != -1
            call add(sep_list, match2[0])
            call add(sep_pos_list, [match2[1], match2[2]])
            call add(match_list, strpart(a:line, match1[2], (match2[1] - match1[2])))
            let match1 = match2
            let match2 = matchstrpos(a:line, pattern, match1[2])
        endwhile
    endif
    return [ match_list, sep_pos_list, sep_list ]
endfunction

function GetCursorType(table, linenr) abort
    if !a:table.valid
        return ''
    endif
    let placement_id = a:linenr - a:table.placement.row_start
    if placement_id < 0 || placement_id >= len(a:table.placement.positions)
        return ''
    endif
    let type = a:table.placement.positions[placement_id]['type']
    if type =~# '\v^row|incomplete$'
        return 'cell'
    elseif type =~# '\v^alignment$'
        return 'alignment'
    elseif type =~# '\v^top|bottom|separator$'
        return 'separator'
    else
        throw 'unknown line type: ' .. type
    endif
endfunction

function GetCursorCoord(table, pos) abort
    if !a:table.valid
        return {'type': 'invalid', 'coord': []}
    endif
    let coord = { 'type': GetCursorType(a:table, a:pos[0]), 'coord': [] }

    let placement_id = a:pos[0] - a:table.placement.row_start
    if placement_id < 0 || placement_id >= len(a:table.placement.positions)
        return {'type': 'invalid', 'coord': []}
    endif
    
    let row_id     = a:table.placement.positions[placement_id]['row_id']
    let row_offset = a:table.placement.positions[placement_id]['row_offset']
    let sep_pos    = a:table.placement.positions[placement_id]['separator_pos']

    if coord.type ==# 'cell'
        let row = max([0, row_id])
        let offset = max([0, row_offset])
        let boundaries = map(copy(sep_pos), 'v:val[0] + 1')
        let col = SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ row, offset, col ]
    elseif coord.type ==# 'alignment'
        let boundaries = []
        for j in range(len(sep_pos)-1)
            " left boundary is exact, right boundary relies on previous char's
            " strlen. We just need the alignment boundary, so this is sufficient
            " for the right boundary.
            call add(boundaries, sep_pos[j][1] + 1)
            call add(boundaries, sep_pos[j][1] + 2)
        endfor
        let col = SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ col ]
    elseif coord.type ==# 'separator'
        let boundaries = map(copy(sep_pos), 'v:val[0] + 1')
        let col = SearchSorted(a:pos[1], boundaries)
        let coord.coord = [ row_id, col ]
    else
        throw 'unsupported cursor type: ' .. coord.type
    endif
    return coord
endfunction

" unoptimized linear search
" if on a boundary, returns index of the boundary
" otherwise, returns index of the left boundary
function SearchSorted(x, list) abort
    if empty(a:list)
        return -1
    endif
    let n = len(a:list)
    for i in range(n)
        if a:x < a:list[i]
            return i - 1
        endif
    endfor
    return i
endfunction

function SetCursorCoord(table, coord) abort
    if !a:table.valid
        return
    endif
    if a:coord.type ==# 'cell'
        call SetCursorCell(a:table, a:coord.coord)
    elseif a:coord.type ==# 'alignment'
        call SetCursorAlignmentSeparator(a:table, a:coord.coord[0])
    elseif a:coord.type ==# 'separator'
        call SetCursorSeparator(a:table, a:coord.coord)
    else
        throw 'unsupported cursor type: ' .. a:coord.type
    endif
endfunction

function SetCursorCell(table, cell_id) abort
    let [row_id, row_offset, col_id] = a:cell_id
    let pos_id = a:table.rows[row_id].placement_id + row_offset

    let linenr = a:table.placement.row_start + pos_id
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let col = 0

    let row_cells = a:table.rows[row_id].cells
    if col_id < 0 || col_id > len(row_cells)
        return
    elseif col_id == len(row_cells)
        let col = sep_pos[-1][1] + 1
    else
        if len(sep_pos) > col_id
            "separator is found on this pos_id
            let col = sep_pos[col_id][1]
            let matchpos = matchstrpos(row_cells[col_id][row_offset], '\m\S')
            if matchpos[1] != -1
                let col += matchpos[1] + 1
            else
                " off of separator with one space of padding
                let col += 2
            endif
        else
            "separator not found, search downwards in the same cell
            let col = FindCellSepCol(a:table, a:cell_id)
        endif
    endif
    call cursor(linenr, col)
endfunction

"TODO: find closest separator to row_offset
function FindCellSepCol(table, cell_id) abort
    let [row_id, _, col_id] = a:cell_id

    " " check if separator exists on the current pos_id
    " let pos_id = a:table.rows[row_id].placement_id + row_offset
    " let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    " if len(sep_pos) > col_id
    "     return sep_pos[col_id][1]
    " endif

    " separator not found, search downwards in the same cell
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

function SetCursorAlignmentSeparator(table, col_id) abort
    let id = a:table.placement.align_id

    let linenr = a:table.placement.row_start + id
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

function SetCursorSeparator(table, sep_id) abort
    let [row_id, col_id] = a:sep_id
    let row = a:table.rows[row_id]
    let pos_id = row.placement_id + row.Height()

    let linenr = a:table.placement.row_start + pos_id
    let sep_pos = a:table.placement.positions[pos_id]['separator_pos']
    let col = 0

    if col_id < 0 || col_id >= len(sep_pos)
        return
    else
        let col = sep_pos[col_id][1]
    endif
    call cursor(linenr, col)
endfunction

function Step2D(vec, xbounds, ybound, ...) abort
    if len(a:vec) != 2
        throw 'vec must be of length 2'
    endif
    let opts = get(a:000, 0, {})
    let step = get(opts, 'step', 1)
    let least_significant = get(opts, 'least_significant', 'left')
    let out = least_significant ==# 'left' ? a:vec : [a:vec[1], a:vec[0]]

    if step >= 0
        let out[0] += 1
        if out[0] >= a:xbounds[out[1]]
            let out[1] += 1
            let out[0] = 0
            if out[1] >= a:ybound
                let out[1] = 0
            endif
        endif
    else
        let out[0] -= 1
        if out[0] < 0
            let out[1] -= 1
            let out[0] = a:xbounds[out[1]] - 1
            if out[1] < 0
                let out[1] = a:ybound - 1
            endif
        endif
    endif

    let out = least_significant ==# 'left' ? out : [out[1], out[0]]
    return out
endfunction

function ComputeWidths(table) abort
    let widths = []
    for col in range(a:table.ColCount())
        let max_width = 0
        for row in a:table.rows
            let cell = get(row.cells, col, '')
            let max_width = max([max_width, CellStrDisplayWidth(cell)])
        endfor
        call add(widths, max_width)
    endfor
    return widths
endfunction

function FindTableRange(linenr) abort
    if !table#IsTable(a:linenr)
        return [-1, -1]
    endif
    let top = a:linenr
    while table#IsTable(top-1)
        let top -= 1
    endwhile
    let bottom = a:linenr
    while table#IsTable(bottom+1)
        let bottom += 1
    endwhile
    return [top, bottom]
endfunction

function TrimCells(table) abort
    for row in a:table.rows
        for j in range(len(row.cells))
            if g:multiline_cells_presever_indentation
                call TrimBlock(row.cells[j], a:table.ColAlign(j))
            else
                for i in range(row.Height())
                    let row.cells[j][i] = trim(row.cells[j][i])
                endfor
            endif
        endfor
    endfor
    let a:table.col_widths = ComputeWidths(a:table)
endfunction

function TrimBlock(lines, alignment) abort
    if empty(a:lines)
        return
    endif
    if len(a:lines) == 1
        let a:lines[0] = trim(a:lines[0])
    else
        for i in range(len(a:lines))
            if a:alignment ==# 'l'
                " trim trailing whitespace
                let a:lines[i] = trim(a:lines[i], '', 2)
            elseif a:alignment ==# 'r'
                " trim leading whitespace
                let a:lines[i] = trim(a:lines[i], '', 1)
            endif
        endfor
    endif

    if a:alignment =~# '\v^l|c$'
        let [indent, indices] = MinTrimIndent(a:lines, 'left')
        for i in indices
            let a:lines[i] = strpart(a:lines[i], indent)
        endfor
    endif
    if a:alignment =~# '\v^r|c$'
        let [indent, indices] = MinTrimIndent(a:lines, 'right')
        for i in indices
            let a:lines[i] = strpart(a:lines[i], 0, strlen(a:lines[i]) - indent)
        endfor
    endif
endfunction

function MinTrimIndent(lines, side) abort
    let trim_indices = []

    if a:side ==# 'left'
        let min_indent = -1
        for i in range(len(a:lines))
            let [match, start, _] = matchstrpos(a:lines[i], '\S')
            let indent = strdisplaywidth(strpart(a:lines[i], 0, start))
            if indent > 0
                call add(trim_indices, i)
                let min_indent = (min_indent == -1) ? indent : min([min_indent, indent])
            endif
        endfor
        return [ min_indent, trim_indices ]
    elseif a:side ==# 'right'
        let min_indent = -1
        for i in range(len(a:lines))
            let [match, start, end] = matchstrpos(a:lines[i], '\S\ze\s*$')
            let indent = strdisplaywidth(strpart(a:lines[i], end))
            if indent > 0
                call add(trim_indices, i)
                let min_indent = (min_indent == -1) ? indent : min([min_indent, indent])
            endif
        endfor
        return [ min_indent, trim_indices ]
    else
        throw 'unknown side: ' .. a:side
    endif
endfunction

function SeparatorAlignment(cell) abort
    let cell = trim(a:cell)
    let left = cell[0] ==# ':'
    let right = cell[-1:] ==# ':'
    if left && right
        return 'c'
    elseif left
        return 'l'
    elseif right
        return 'r'
    else
        return ''
    endif
endfunction

" function MatchCount(line, pattern, stop) abort
"     let count = 0
"     let start = 0
"     while v:true
"         let match = matchstrpos(a:line, a:pattern, start)
"         if match[1] == -1 || match[1] > a:stop
"             break
"         endif
"         let count += 1
"         let start = match[2]
"     endwhile
"     return count
" endfunction

" function Erase(table) abort
"     " pads to max_col_start in order to allow redrawing later
"     let placement = a:table.placement
"     let linenr = placement.row_start
"     for i in a:table.placement.row_count
"         let row = a:table.rows[i]
"         let line = getline(linenr)
"         let newline = strpart(line, 0, placement.col_start[i]-1)
"         let newline ..= repeat(' ', placement.max_col_start - placement.col_start[i])
"         let newline ..= strpart(line, placement.col_end[i]-1)
"         call setline(linenr, newline)
"
"         let placement.col_start[i] = placement.max_col_start
"         let placement.col_end[i] = placement.max_col_start
"         let linenr += 1
"     endfor
" endfunction
"
" function Insert(table, pos) abort
"     call AlignCells(a:table)
"     let a:table.placement.row_start = a:pos[1]
"     let a:table.placement.max_col_start = a:pos[2]
"     let a:table.placement.col_start = repeat([a:pos[2]], a:table.placement.row_count)
"     let a:table.placement.col_end = repeat([a:pos[2]], a:table.placement.row_count)
"     call Draw(a:table, v:false)
" endfunction

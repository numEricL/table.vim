function! table#table#Get(linenr) abort
    let bounds = table#parse#FindTableRange(a:linenr)
    if bounds[0] == -1
        return {'valid': v:false}
    endif
    let placement = {
                \ 'row_start'     : bounds[0],
                \ 'positions'     : [],
                \ 'align_id'      : -1,
                \ 'max_col_start' : 0,
                \ }
    let table = {
                \ 'valid'         : v:true,
                \ 'placement'     : placement,
                \ 'rows'          : [],
                \ 'col_align'     : [],
                \ 'col_widths'    : [],
                \ 'max_col_count' : 0,
                \ 'RowCount'      : function('s:TableRowCount'),
                \ 'ColCount'      : function('s:TableColCount'),
                \ 'ColAlign'      : function('s:TableColAlign'),
                \ 'Cell'          : function('s:TableGetCell'),
                \ 'SetCell'       : function('s:TableSetCell'),
                \ }

    let last_type = 'separator'
    for pos_id in range(bounds[1] - bounds[0] + 1)
        let [line_cells, col_start, sep_pos, type] = table#parse#ParseLine(bounds[0] + pos_id)
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
            call s:TableAppendRow(table, type, last_type, line_cells, pos_id)
            let table.max_col_count = max([table.max_col_count, len(line_cells)])
        endif
        let last_type = type

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
                call add(table.col_align, table#parse#SeparatorAlignment(cell))
            endfor
            let table.max_col_count = max([table.max_col_count, len(line_cells)])
        endif
    endfor
    let table.col_widths = table#util#ComputeWidths(table)
    let g:t = table
    return table
endfunction

function! s:TableRowCount() dict abort
    return len(self.rows)
endfunction

function! s:TableColCount() dict abort
    return self.max_col_count
endfunction

function! s:TableColAlign(col) dict abort
    let cfg_opts = table#config#Config().options
    let default_align = cfg_opts.default_alignment
    let align = get(self.col_align, a:col, default_align)
    return empty(align)? default_align : align
endfunction

function! s:TableGetCell(row, col) dict abort
    let row_obj = self.rows[a:row]
    if a:col >= row_obj.ColCount()
        return []
    endif
    return copy(row_obj.cells[a:col])
endfunction

function! s:TableSetCell(row, col, cell) dict abort
    if type(a:cell) != v:t_list
        throw 'cell must be a list of strings'
    endif
    let row_obj = self.rows[a:row]
    let self.rows[a:row].cells[a:col] = a:cell
endfunction

function! s:CellColCount() dict abort
    return len(self.cells)
endfunction

function! s:CellRowHeight() dict abort
    let height = 0
    for cell in self.cells
        let height = max([height, len(cell)])
    endfor
    return height
endfunction

function! s:TableAppendRow(table, line_type, last_type, line_cells, pos_id) abort
    let cfg_opts = table#config#Config().options
    if !cfg_opts.multiline_cells_enable ||  a:last_type =~# '\v' .. 'separator|alignment|top|bottom'
        let cells = empty(a:line_cells)? [['']] : map(copy(a:line_cells), '[v:val]')
        let row = {
                    \ 'cells'         : cells,
                    \ 'types'         : [ a:line_type ],
                    \ 'placement_id'  : a:pos_id,
                    \ 'Height'        : function('s:CellRowHeight'),
                    \ 'ColCount'      : function('s:CellColCount'),
                    \ }
        call add(a:table.rows, row)
    else
        let row = a:table.rows[-1]
        while len(row.cells) < len(a:line_cells)
            call add(row.cells, [''])
        endwhile
        for j in range(len(row.cells))
            call add(row.cells[j], get(a:line_cells, j, ''))
        endfor
        call add(row.types, a:line_type)
    endif
endfunction

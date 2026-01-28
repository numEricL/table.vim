let s:cache_table = v:false

function! table#table#Get(linenr, chunk_size, ...) abort
    let cache_table = a:0 ? a:1 : s:cache_table
    if !cache_table
        return s:Generate(a:linenr, a:chunk_size)
    else
        throw 'caching disabled'
        " return s:TryCache(a:linenr, a:chunk_size)
    endif
endfunction

function! s:ComputeChunkBounds(linenr, full_bounds, chunk_size) abort
    if a:chunk_size == [0, -1]
        return a:full_bounds
    endif

    let start_line = a:linenr + a:chunk_size[0]
    let end_line = a:linenr + a:chunk_size[1]

    let start_line = max([a:full_bounds[0], start_line])
    let end_line = min([a:full_bounds[1], end_line])

    let [start_line, end_line] = s:ExpandEmptyChunk(start_line, end_line, a:full_bounds)
    let start_line = s:ExpandToCompleteRow(start_line, a:full_bounds[0], -1)
    let end_line = s:ExpandToCompleteRow(end_line, a:full_bounds[1], 1)

    return [start_line, end_line]
endfunction

function! s:ExpandEmptyChunk(start_line, end_line, full_bounds) abort
    if a:start_line == a:end_line
        let [_, _, _, type] = table#parse#ParseLine(a:start_line)
        if type =~# '\v^separator|alignment|top|bottom$'
            " try expanding downwards
            let current = a:start_line + 1
            while current <= a:full_bounds[1]
                let [_, _, _, type] = table#parse#ParseLine(current)
                if type =~# '\v^row|incomplete$'
                    return [a:start_line, current]
                else
                    let current += 1
                endif
            endwhile
            " try expanding upwards
            let current = a:start_line - 1
            while current >= a:full_bounds[0]
                let [_, _, _, type] = table#parse#ParseLine(current)
                if type =~# '\v^row|incomplete$'
                    return [current, a:end_line]
                else
                    let current -= 1
                endif
            endwhile
        endif
    endif       
    return [a:start_line, a:end_line]
endfunction

function! s:ExpandToCompleteRow(linenr, boundary, direction) abort
    let current = a:linenr
    let cfg_opts = table#config#Config().options
    if !cfg_opts.multiline
        let [_, _, _, type] = table#parse#ParseLine(current)
        if type =~# '\v^row|incomplete$' && current != a:boundary
            let [_, _, _, type] = table#parse#ParseLine(current + a:direction)
            if type =~# '\v^separator|alignment|top|bottom$'
                let current += a:direction
            endif
        endif
    else
        while current != a:boundary
            let [_, _, _, type] = table#parse#ParseLine(current)
            if type =~# '\v^separator|alignment|top|bottom$'
                break
            endif
            let next = current + a:direction
            if next < 1 || next > line('$')
                break
            endif
            if (a:direction == -1 && next < a:boundary) || (a:direction == 1 && next > a:boundary)
                break
            endif
            let current = next
        endwhile
    endif
    return current
endfunction

function! s:Generate(linenr, chunk_size) abort
    let full_bounds = table#parse#FindTableRange(a:linenr)
    if full_bounds[0] == -1
        return {'valid': v:false}
    endif
    let bounds = s:ComputeChunkBounds(a:linenr, full_bounds, a:chunk_size)
    let placement = {
                \ 'bounds'        : bounds,
                \ 'full_bounds'   : full_bounds,
                \ 'positions'     : [],
                \ 'align_id'      : -1,
                \ 'min_col_start' : -1,
                \ 'max_col_start' : -1,
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
            if pos_id == 0 && (bounds[0] == full_bounds[0]) " top chunk
                let type = 'top'
            elseif pos_id == (bounds[1] - bounds[0]) && (bounds[1] == full_bounds[1]) " bottom chunk
                let type = 'bottom'
            endif
        endif

        if type =~# '\v^(row|incomplete)$'
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
        let placement.min_col_start = (placement.min_col_start == -1)? col_start : min([placement.min_col_start, col_start])
        let placement.max_col_start = max([placement.max_col_start, col_start])

        if type ==# 'alignment' && placement.align_id == -1
            let placement.align_id = pos_id
            for cell in line_cells
                call add(table.col_align, table#parse#SeparatorAlignment(cell))
            endfor
            let table.max_col_count = max([table.max_col_count, len(line_cells)])
        endif
    endfor
    let table.col_widths = table#util#ComputeWidths(table)
    " TEMP: for debugging
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

function! s:TableSetCell(row, col, lines) dict abort
    if len(a:lines) > 1
        execute('Table Option multiline 1')
    endif
    let row_obj = self.rows[a:row]
    let self.rows[a:row].cells[a:col] = a:lines
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
    if !cfg_opts.multiline ||  a:last_type =~# '\v' .. 'separator|alignment|top|bottom'
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

function! s:TryCache(linenr, chunk_size) abort
    " cache initialization
    if !exists('b:table_cache')
        let b:table_cache = {}
        let b:table_cache_bounds = []
        call s:SetupCacheInvalidation()
    endif

    " check cache
    for i in range(len(b:table_cache_bounds))
        let bounds = b:table_cache_bounds[i]
        if a:linenr >= bounds[0] && a:linenr <= bounds[1]
            let cache_key = string(bounds)
            if has_key(b:table_cache, cache_key)
                return b:table_cache[cache_key]
            endif
        endif
    endfor

    let table = table#table#Get(a:linenr, a:chunk_size, v:false)
    if table.valid
        let bounds = table.placement.bounds
        let cache_key = string(bounds)
        let b:table_cache[cache_key] = table

        " track bounds for invalidation
        let found = v:false
        for existing_bounds in b:table_cache_bounds
            if existing_bounds == bounds
                let found = v:true
                break
            endif
        endfor
        if !found
            call add(b:table_cache_bounds, bounds)
        endif
    endif

    return table
endfunction

function! table#table#InvalidateCache() abort
    if exists('b:table_cache')
        let b:table_cache = {}
        let b:table_cache_bounds = []
    endif
endfunction

function! s:SetupCacheInvalidation() abort
    augroup TableCacheInvalidation
        autocmd! * <buffer>
        autocmd TextChanged,TextChangedI <buffer> call table#table#InvalidateCache()
    augroup END
endfunction

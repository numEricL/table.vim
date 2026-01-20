function! table#draw#Incomplete(table) abort
    let pos_id = 0
    let new_id = 0
    while pos_id < len(a:table.placement.positions)
        let line_type = a:table.placement.positions[pos_id].type
        if line_type =~# '\v^top|bottom|separator|alignment$'
            let linenr = a:table.placement.row_start + pos_id
            let num_cols = len(table#parse#ParseLine(linenr)[0])
            let num_cols = (num_cols == 0)? a:table.ColCount() : num_cols
            let new_id = s:DrawSeparator(a:table, new_id, line_type, num_cols)
        elseif line_type =~# '\v^row|incomplete$'
            let row_id = a:table.placement.positions[pos_id].row_id
            let new_id = s:DrawRow(a:table, new_id, row_id, v:false)
            let pos_id += a:table.rows[row_id].Height() - 1
        else
            throw 'unknown line type: ' .. line_type
        endif
        let pos_id += 1
    endwhile
    call s:ClearRemaining(a:table.placement, len(a:table.placement.positions))
    call extend(a:table, table#table#Get(a:table.placement.row_start))
endfunction

function! table#draw#Complete(table) abort
    let row_count = a:table.RowCount()
    if row_count == 0
        return
    endif
    let pos_id = 0
    let cfg_opts = table#config#Config().options
    let style_opts = table#config#Style().options

    if !style_opts.omit_top_border
        let num_cols = a:table.rows[0].ColCount()
        let pos_id = s:DrawSeparator(a:table, pos_id, 'top', num_cols)
    endif
    let pos_id = s:DrawRow(a:table, pos_id, 0)

    if a:table.RowCount() > 1
        let row_id = 0
        let num_cols = max([len(a:table.col_align), a:table.rows[row_id].ColCount(), a:table.rows[row_id+1].ColCount()])
        let pos_id = s:DrawSeparator(a:table, pos_id, 'alignment', num_cols)
    endif

    if a:table.RowCount() > 2
        for row_id in range(1, a:table.RowCount() - 2)
            let pos_id = s:DrawRow(a:table, pos_id, row_id)
            if cfg_opts.multiline_cells || !style_opts.omit_separator_rows
                let num_cols = max([a:table.rows[row_id].ColCount(), a:table.rows[row_id+1].ColCount()])
                let pos_id = s:DrawSeparator(a:table, pos_id, 'separator', num_cols)
            endif
        endfor
    endif

    if a:table.RowCount() > 1
        let pos_id = s:DrawRow(a:table, pos_id, a:table.RowCount() - 1)
    endif

    if !style_opts.omit_bottom_border
        let num_cols = a:table.rows[-1].ColCount()
        let pos_id = s:DrawSeparator(a:table, pos_id, 'bottom', num_cols)
    endif
    call s:ClearRemaining(a:table.placement, pos_id)
    call extend(a:table, table#table#Get(a:table.placement.row_start))
endfunction

function! s:DrawLine(placement, pos_id, line) abort
    if a:pos_id > len(a:placement.positions)
        throw 'pos_id out of range'
    endif
    if empty(a:line)
        return a:pos_id
    endif
    let [col_start, col_end] = [-1, -1]

    let display_col_start = a:placement.max_col_start
    let cfg_opts = table#config#Config().options
    let style_opts = table#config#Style().options
    if style_opts.omit_left_border
        let display_col_start = a:placement.min_col_start
        if a:placement.align_id == -1 && style_opts.omit_separator_rows && !cfg_opts.multiline_cells
            let display_col_start -= 1
        endif
    endif

    if a:pos_id == len(a:placement.positions)
        let linenr = a:placement.row_start + len(a:placement.positions) - 1
        call s:AppendConditionalCommentLine(linenr)
        let [col_start, col_end] = [display_col_start, display_col_start]
        call add(a:placement.positions, {})
    elseif style_opts.omit_left_border
        let col_start = display_col_start
        let col_end   = a:placement.positions[a:pos_id]['separator_pos'][-1][1]
    else
        let col_start = a:placement.positions[a:pos_id]['separator_pos'][0][0]
        let col_end   = a:placement.positions[a:pos_id]['separator_pos'][-1][1]
    endif

    let linenr = a:placement.row_start + a:pos_id
    let current_line = getline(linenr)
    let newline = strpart(current_line, 0, col_start)
    let newline ..= repeat(' ', display_col_start - strdisplaywidth(newline))
    let newline ..= a:line
    let newline ..= strpart(current_line, col_end)
    if newline !=# current_line
        call setline(linenr, newline)
    endif
    return a:pos_id + 1
endfunction

function! s:DrawRow(table, pos_id, row_id, ...) abort
    let fill_cell_multirows = get(a:000, 0, v:true)
    let row = a:table.rows[a:row_id]
    let pos_id = a:pos_id
    let cfg_opts = table#config#Config().options
    let style_opts = table#config#Style().options
    let [row_left, row_right, row_sep, row_horiz] = table#config#GetBoxDrawingChars('row')
    
    for i in range(row.Height())
        let fill_cell = fill_cell_multirows || s:HasRightMostSeparator(a:table, a:row_id, i)
        let rowline = ''

        if get(row.types, i, '') ==# 'incomplete'
            let rowline = cfg_opts.i_vertical
        else
            let single_row_cells = []
            for cell in row.cells
                call add(single_row_cells, get(cell, i, ''))
            endfor
            let left  = style_opts.omit_left_border  ? '' : row_left
            let right = style_opts.omit_right_border ? '' : row_right
            let sep = row_sep
            if fill_cell
                let rowline = left .. join(single_row_cells, sep) .. right
            else
                let num_cols = s:NumSubRowCols(a:table, a:row_id, i)
                let rowline = left .. join(single_row_cells[0:num_cols-1], sep) .. sep
            endif
        endif
        if i == 0
            let row.placement_id = pos_id
        endif
        let pos_id = s:DrawLine(a:table.placement, pos_id, rowline)
    endfor
    return pos_id
endfunction

function! s:DrawSeparator(table, pos_id, type, num_cols) abort
    let sep = s:MakeSeparator(a:table, a:type, a:num_cols)
    let pos_id = s:DrawLine(a:table.placement, a:pos_id, sep)
    return pos_id
endfunction

function! s:HasRightMostSeparator(table, row_id, row_offset) abort
    let pos_id = get(a:table.rows[a:row_id], 'placement_id', -1)
    if pos_id == -1
        return v:true
    endif
    let pos_id += a:row_offset
    return len(a:table.placement.positions[pos_id]['separator_pos']) > a:table.rows[a:row_id].ColCount()
endfunction

function! s:NumSubRowCols(table, row_id, row_offset) abort
    let pos_id = a:table.rows[a:row_id].placement_id + a:row_offset
    return len(a:table.placement.positions[pos_id]['separator_pos']) - 1
endfunction

function! s:MakeSeparator(table, type, num_cols) abort
    let [ left, right, sep, horiz ] = table#config#GetBoxDrawingChars(a:type)
    if a:num_cols == 0
        return ''
    endif
    let line = left
    let show_alignment = (a:type ==# 'alignment')
    for i in range(a:num_cols-1)
        let col_align = get(a:table.col_align, i, '')
        let pad_left  = (show_alignment && col_align =~# '\v^l|c$') ? ':' : horiz
        let pad_right = (show_alignment && col_align =~# '\v^r|c$') ? ':' : horiz
        let width = get(a:table.col_widths, i, 2)
        let line ..= pad_left .. repeat(horiz, width) .. pad_right .. sep
    endfor
    let i = a:num_cols - 1
    let col_align = get(a:table.col_align, i, '')
    let pad_left  = (show_alignment && col_align =~# '\v^l|c$') ? ':' : horiz
    let pad_right = (show_alignment && col_align =~# '\v^r|c$') ? ':' : horiz
    let width = get(a:table.col_widths, i, 2)
    let line ..= pad_left .. repeat(horiz, width) .. pad_right .. right
    return line
endfunction

function! s:AppendConditionalCommentLine(linenr) abort
    let cs = split(&commentstring, '%s')
    let found = v:false
    if len(cs) > 0
        let line = getline(a:linenr)
        let cs_pattern = table#util#CommentStringPattern()[0]
        let match = matchstrpos(line, '\V\^' .. cs_pattern)
        let found = match[1] != -1
    endif
    let new_line = found? cs[0] : ''
    call append(a:linenr, new_line)
endfunction

function! s:ClearRemaining(placement, pos_id) abort
    let [cs_left, cs_right] = table#util#CommentStringPattern()
    for id in reverse(range(a:pos_id, len(a:placement.positions)-1))
        let linenr = a:placement.row_start + id
        let line = getline(linenr)
        let newline = strpart(line, 0, a:placement.max_col_start)
        let newline ..= strpart(line, a:placement.positions[id]['separator_pos'][-1][1])
        if newline =~# '\V\^' .. cs_left .. cs_right .. '\$'
            call deletebufline('%', linenr)
        else
            call setline(linenr, newline)
        endif
    endfor
endfunction

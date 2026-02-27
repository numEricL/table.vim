let s:save_cpo = &cpo
set cpo&vim

function! table#format#FillGaps(table) abort
    for row in a:table.rows
        call map(row.types, {_, value -> value ==# 'incomplete' ? '' : value})
        while len(row.cells) < a:table.ColCount()
            call add(row.cells, [''])
        endwhile
    endfor
endfunction

function! table#format#Align(table) abort
    let bufnr = a:table.placement.bufnr
    let cfg_opts = table#config#Config(bufnr).options
    let multiline = a:table.placement.multiline

    for i in range(len(a:table.rows))
        let align_tag_pos = s:AlignmentTagPos(a:table.rows[i])
        let trailing_blank_lines = s:CountTrailingBlankLines(a:table.rows[i])
        for j in range(len(a:table.rows[i].cells))
            let cell = a:table.rows[i].cells[j]
            let width = get(a:table.fixed_widths, j, 0)
            let tag = s:ExtractAlignmentTag(align_tag_pos, cell)
            let cell = s:FormatCell(cell, j, width, multiline, cfg_opts)
            call s:InsertAlignmentTag(align_tag_pos, cell, tag)
            let a:table.rows[i].cells[j] = cell
        endfor
        call s:TrimTrailingBlankLines(a:table.rows[i], trailing_blank_lines)
        call s:RepositionAlignmentTags(a:table.rows[i], align_tag_pos)
    endfor

    let col_widths = table#util#ComputeWidths(a:table)
    for i in range(len(a:table.fixed_widths))
        if a:table.fixed_widths[i] > 0
            let col_widths[i] = max([col_widths[i], a:table.fixed_widths[i]])
        endif
    endfor
    let col_aligns = []
    for i in range(a:table.ColCount())
        call add(col_aligns, a:table.ColAlign(i))
    endfor
    call s:PadAlignCells(a:table, col_aligns, col_widths)
    let a:table.col_widths = col_widths " used in draw.vim for separator lines
endfunction

function! s:CountTrailingBlankLines(row) abort
    let cells = a:row.cells
    let height = a:row.Height()
    let count = -1
    for cell in cells
        let cell_count = height - len(cell)
        let id = len(cell) - 1
        while id >= 0 && cell[id] =~# '^\s*$'
            let cell_count += 1
            let id -= 1
        endwhile
        if count == -1 || cell_count < count
            let count = cell_count
        endif
    endfor
    return count
endfunction

function! s:TrimTrailingBlankLines(row, keep) abort
    if a:keep <= 0
        return
    endif
    let cells = a:row.cells
    let height = a:row.Height()
    for cell in cells
        let removed = height - len(cell)
        let id = len(cell) - 1 - a:keep
        while id >= 0 && cell[id] =~# '^\s*$' && removed < a:keep
            call remove(cell, id)
            let id -= 1
            let removed += 1
        endwhile
    endfor
endfunction

function! s:AlignmentTagPos(row) abort
    if a:row.types[0] ==# 'alignment_tag'
        return 'top'
    elseif a:row.types[-1] ==# 'alignment_tag'
        return 'bottom'
    else
        return ''
    endif
endfunction

function! s:ExtractAlignmentTag(tag_pos, cell) abort
    if a:tag_pos ==# 'top'
        return trim(remove(a:cell, 0))
    elseif a:tag_pos ==# 'bottom'
        return trim(remove(a:cell, len(a:cell) - 1))
    else
        return ''
    endif
endfunction

function! s:InsertAlignmentTag(tag_pos, cell, tag) abort
    if a:tag_pos ==# 'top'
        call insert(a:cell, a:tag, 0)
    elseif a:tag_pos ==# 'bottom'
        call add(a:cell, a:tag)
    endif
endfunction

function! s:RepositionAlignmentTags(row, tag_pos) abort
    if a:tag_pos ==# 'bottom'
        let height = a:row.Height()
        for cell in a:row.cells
            while len(cell) < height
                call insert(cell, '', -1)
            endwhile
        endfor
    endif
endfunction

function! s:FormatCell(lines, col_idx, width, multiline, cfg_opts) abort
    if empty(a:lines)
        return []
    endif
    let lines = a:lines
    if !a:multiline
        call s:TrimLinewise(lines)
    else
        if a:cfg_opts.multiline_format =~# '\v^(block_align|block_wrap)$'
            call s:TrimBlock(lines)
        else
            call s:TrimLinewise(lines)
        endif
        if a:cfg_opts.multiline_format ==# 'paragraph_wrap'
            if a:width > 0
                let lines = s:ParagraphJoin(lines)
            endif
        endif
        if a:cfg_opts.multiline_format =~# '\v^(wrap|block_wrap|paragraph_wrap)$'
            let lines = s:WrapCell(lines, a:width)
        endif
    endif
    return lines
endfunction

function! s:ParagraphJoin(lines) abort
    let result = []
    let paragraph = []
    for line in a:lines
        if line =~# '^\s*$'
            if !empty(paragraph)
                call add(result, join(paragraph))
                let paragraph = []
            endif
            call add(result, '')
        else
            call add(paragraph, line)
        endif
    endfor
    if !empty(paragraph)
        call add(result, join(paragraph))
    endif
    return result
endfunction

function! s:PadAlignCells(table, aligns, widths) abort
    for row in a:table.rows
        for j in range(len(row.cells))
            let cell = row.cells[j]
            let align = a:aligns[j]
            let width = a:widths[j]
            for i in range(row.Height())
                if i < len(cell)
                    let cell[i] = ' ' .. s:PadAlignLine(cell[i], align, width) .. ' '
                else
                    call add(cell, ' ' .. s:PadAlignLine('', align, width) .. ' ')
                endif
            endfor
        endfor
    endfor
endfunction

function! s:PadAlignLine(line, align, width) abort
    let pad_size = a:width - strdisplaywidth(a:line)
    let line = a:line
    if a:align ==# 'l'
        let line = line .. repeat(' ', pad_size)
    elseif a:align ==# 'r'
        let line = repeat(' ', pad_size) .. line
    elseif a:align ==# 'c'
        let left_pad = float2nr(floor(pad_size / 2))
        let right_pad = pad_size - left_pad
        let line = repeat(' ', left_pad) .. line .. repeat(' ', right_pad)
    else
        throw 'unknown alignment: ' .. a:align .. ' (should be l, r, or c)'
    endif
    return line
endfunction

function! s:TrimLinewise(lines) abort
    for i in range(len(a:lines))
        let a:lines[i] = trim(a:lines[i])
    endfor
endfunction

function! s:TrimBlock(lines) abort
    if empty(a:lines)
        return
    endif
    if len(a:lines) == 1
        let a:lines[0] = trim(a:lines[0])
    else
        for i in range(len(a:lines))
            let a:lines[i] = table#compat#trim(a:lines[i], '', 2)
        endfor
    endif

    let indent = s:MinTrimIndent(a:lines, 'left')
    for i in range(len(a:lines))
        let a:lines[i] = strpart(a:lines[i], indent)
    endfor
    let width = table#util#CellStrDisplayWidth(a:lines)
    for i in range(len(a:lines))
        let a:lines[i] = s:PadAlignLine(a:lines[i], 'l', width)
    endfor
endfunction

function! s:MinTrimIndent(lines, side) abort
    let min_indent = -1
    let indent = -1
    for i in range(len(a:lines))
        if a:side ==# 'left'
            let [_, indent, _] = matchstrpos(a:lines[i], '\S')
        elseif a:side ==# 'right'
            let [_, _, end] = matchstrpos(a:lines[i], '\S\ze\s*$')
            let indent = (end != -1) ? (strlen(a:lines[i]) - end) : -1
        endif
        if indent >= 0
            let min_indent = (min_indent == -1) ? indent : min([min_indent, indent])
        endif
    endfor
    return min_indent
endfunction

function! s:WrapCell(cell, width) abort
    if empty(a:cell) || a:width <= 0
        return a:cell
    endif
    let new_cell = []
    for i in range(len(a:cell))
        if strdisplaywidth(a:cell[i]) > a:width
            call extend(new_cell, s:WrapLine(a:cell[i], a:width))
        else
            call add(new_cell, a:cell[i])
        endif
    endfor
    return new_cell
endfunction

function! s:WrapLine(line, width) abort
    let result = []
    let text = a:line
    while strdisplaywidth(text) > a:width
        let byte_width = table#util#DisplayWidthToByteWidth(text, a:width)
        let break_at = -1
        if strpart(text, byte_width, 1) =~# '\s'
            let break_at = byte_width
        else
            let chunk = strpart(text, 0, byte_width)
            let break_at = match(chunk, '\s\zs\S\+$')
        endif
        if break_at == -1 || break_at == 0
            let break_at = byte_width
        endif
        let line_part = strpart(text, 0, break_at)
        let line_part = substitute(line_part, '\s\+$', '', '')
        call add(result, line_part)
        let text = substitute(strpart(text, break_at), '^\s\+', '', '')
    endwhile
    if strlen(text)
        call add(result, text)
    endif
    return result
endfunction

" function! s:TrimBlankLines(lines) abort
"     " remove empty lines from the top
"     while len(a:lines) > 1 && (a:lines[0] =~# '^\s*$')
"         call remove(a:lines, 0)
"     endwhile
"     " remove empty lines from the bottom
"     while len(a:lines) > 1 && (a:lines[-1] =~# '^\s*$')
"         call remove(a:lines, len(a:lines) - 1)
"     endwhile
"     return a:lines
" endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

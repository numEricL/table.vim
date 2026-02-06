let s:save_cpo = &cpo
set cpo&vim

function! table#format#FillGaps(table) abort
    for row in a:table.rows
        let row.types = repeat(['row'], row.Height())
        while len(row.cells) < a:table.ColCount()
            call add(row.cells, [''])
        endwhile
    endfor
endfunction

function! table#format#Align(table) abort
    call s:TrimCells(a:table)
    let widths = a:table.col_widths
    for row in a:table.rows
        for j in range(len(row.cells))
            let cell = row.cells[j]
            let align = a:table.ColAlign(j)
            let width = widths[j]
            for i in range(row.Height())
                if i < len(cell)
                    let cell[i] = s:PadAlignLine(cell[i], align, width)
                else
                    call add(cell, s:PadAlignLine('', align, width))
                endif
            endfor
        endfor
    endfor
endfunction

function! s:PadAlignLine(line, align, width) abort
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

function! s:TrimCells(table) abort
    let bufnr = a:table.placement.bufnr
    let cfg_opts = table#config#Config(bufnr).options
    for row in a:table.rows
        for j in range(len(row.cells))
            if cfg_opts.multiline && cfg_opts.preserve_indentation
                call s:TrimBlock(row.cells[j], a:table.ColAlign(j))
            else
                for i in range(len(row.cells[j]))
                    let row.cells[j][i] = trim(row.cells[j][i])
                endfor
            endif
        endfor
    endfor
    let a:table.col_widths = table#util#ComputeWidths(a:table)
endfunction

function! s:TrimBlock(lines, alignment) abort
    if empty(a:lines)
        return
    endif
    if len(a:lines) == 1
        let a:lines[0] = trim(a:lines[0])
    else
        for i in range(len(a:lines))
            if a:alignment ==# 'l'
                let a:lines[i] = trim(a:lines[i], '', 2)
            elseif a:alignment ==# 'r'
                let a:lines[i] = trim(a:lines[i], '', 1)
            endif
        endfor
    endif

    if a:alignment =~# '\v^l|c$'
        let indent = s:MinTrimIndent(a:lines, 'left')
        for i in range(len(a:lines))
            let a:lines[i] = strpart(a:lines[i], indent)
        endfor
    endif
    if a:alignment =~# '\v^r|c$'
        let indent = s:MinTrimIndent(a:lines, 'right')
        for i in range(len(a:lines))
            let a:lines[i] = strpart(a:lines[i], 0, strlen(a:lines[i]) - indent)
        endfor
    endif
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

let &cpo = s:save_cpo
unlet s:save_cpo

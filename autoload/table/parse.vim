let s:save_cpo = &cpo
set cpo&vim

function! table#parse#FindTableRange(linenr) abort
    if !s:IsTableLine(a:linenr)
        return [-1, -1]
    endif
    let view = {}
    let move_cursor = ( line('.') != a:linenr )
    if move_cursor
        let view = winsaveview()
        call cursor(a:linenr, 1)
    endif
    let cs = table#util#CommentStringPattern(bufnr('%'))
    let empty_line = '\V\^' .. cs[0] .. cs[1] .. '\$'
    let top = search(empty_line, 'bnW')
    let top = (top == 0) ? 1 : top + 1
    let bottom = search(empty_line, 'nW')
    let bottom = (bottom == 0) ? line('$') : bottom - 1
    if move_cursor
        call winrestview(view)
    endif
    if !s:IsTableLine(top) || !s:IsTableLine(bottom)
        return [-1, -1]
    endif
    return [top, bottom]
endfunction

" type may be: 'row', 'separator', 'alignment', 'incomplete'
function! table#parse#ParseLine(linenr) abort
    let line = getline(a:linenr)
    let [line_stripped, prefix, _] = s:CommentAwareTrim(line)
    let [cells, sep_pos, seps] = s:SplitPos(line_stripped)
    let [cells, sep_pos] = s:HandleOmittedBorders(line_stripped, cells, sep_pos)

    " strip lines of text before/after the table borders for determining type
    let line_table_only = strpart(line_stripped, sep_pos[0][0], sep_pos[-1][1] - sep_pos[0][0])
    let type = s:LineType(line_table_only)

    if empty(cells)
        let [ sep_pos, type ] = s:ParseIncompleteBorders(line_stripped, seps, sep_pos)
    endif
    if type ==# 'separator' && s:CheckAlignmentSeparator(line_stripped)
        let type = 'alignment'
    endif
    let offset = prefix[2]
    call map(sep_pos, '[v:val[0] + offset, v:val[1] + offset]')
    let col_start = strdisplaywidth(strpart(line, 0, sep_pos[0][0]))
    return [ cells, col_start, sep_pos, type ]
endfunction

function! table#parse#SeparatorAlignment(cell) abort
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

function! s:IsTableLine(linenr) abort
    let line = getline(a:linenr)
    let prev = getline(a:linenr-1)
    let next = getline(a:linenr+1)

    if s:IsTableFormat(line)
        if s:IsTableFormat(prev) || s:IsIncompleteTableLine(prev)
            return v:true
        elseif s:IsTableFormat(next) || s:IsIncompleteTableLine(next)
            return v:true
        endif
    elseif s:IsIncompleteTableLine(line)
        if s:IsTableFormat(prev) || s:IsTableFormat(next)
            return v:true
        endif
    endif
    return v:false
endfunction

function! s:CheckAlignmentSeparator(line) abort
    let cfg_opts = table#config#Config(bufnr('%')).options
    let pat = table#util#AnyPattern([cfg_opts.i_alignment])
    return a:line =~# '\V' .. pat
endfunction

function! s:IsTableFormat(line) abort
    let sep = s:GeneralSeparatorPattern()
    let style_opts = table#config#Style(bufnr('%')).options
    if style_opts.omit_left_border && style_opts.omit_right_border
        if a:line =~# '\V' .. sep
            return v:true
        endif
    else
        if a:line =~# '\V' .. sep .. '\.\*' .. sep
            return v:true
        endif
    endif

    let cs = table#util#CommentStringPattern(bufnr('%'))[0]
    let horiz = s:GeneralHorizPattern()
    if a:line =~# '\V\^' .. cs .. horiz .. '\+\s\*\$'
        return v:true
    endif
    return v:false
endfunction

function! s:IsIncompleteTableLine(line) abort
    let cs = table#util#CommentStringPattern(bufnr('%'))[0]
    let sep = s:GeneralSeparatorPattern()
    if a:line =~# '\V\^' .. cs .. sep
        return v:true
    endif
    return v:false
endfunction

function! s:LineType(line) abort
    let sep_line = s:GeneralSeparatorLinePattern()
    let horiz = s:GeneralHorizPattern()
    if a:line =~# '\V\^' .. sep_line .. '\+\$' && a:line =~# '\V' .. horiz
        return 'separator'
    else
        return 'row'
    endif
endfunction

function! s:ParseIncompleteBorders(line, seps, sep_pos) abort
    let horiz = s:GeneralHorizPattern()
    let type = ''
    if empty(a:seps)
        let match = matchstrpos(a:line, '\V' .. horiz .. '\+')
        call add(a:sep_pos, [match[1], match[1]])
        call add(a:sep_pos, [match[2], match[2]])
        let type = 'separator'
    else
        let match = matchstrpos(a:line, '\V' .. horiz .. '\+', a:sep_pos[0][1])
        if match[1] != -1
            call add(a:sep_pos, match[1:2])
            let type = 'separator'
        else
            let type = 'incomplete'
        endif
    endif
    return [ a:sep_pos, type ]
endfunction

function! s:BoxDrawingPatterns(type) abort
    " sep = [ left, right, sep, horiz ]
    let sep = table#config#GetBoxDrawingChars(bufnr('%'), a:type)
    let cfg_opts = table#config#Config(bufnr('%')).options
    for i in range(3)
        let sep[i] = table#util#AnyPattern([sep[i], cfg_opts.i_vertical])
    endfor
    if a:type ==# 'alignment'
        let sep[3] = table#util#AnyPattern([sep[i], cfg_opts.i_horizontal, ':'])
    else
        let sep[3] = table#util#AnyPattern([sep[i], cfg_opts.i_horizontal])
    endif
    let style_opts = table#config#Style(bufnr('%')).options
    let sep[0] = style_opts.omit_left_border  ? '' : sep[0]
    let sep[1] = style_opts.omit_right_border ? '' : sep[1]
    return sep
endfunction

function! s:GeneralSeparatorPattern() abort
    let box = table#config#Style(bufnr('%')).box_drawing
    let cfg_opts = table#config#Config(bufnr('%')).options
    let separators = [
                \ box.align_left,
                \ box.align_right,
                \ box.align_sep,
                \ box.sep_left,
                \ box.sep_right,
                \ box.sep_sep,
                \ box.top_left,
                \ box.top_right,
                \ box.top_sep,
                \ box.bottom_left,
                \ box.bottom_right,
                \ box.bottom_sep,
                \ box.row_left,
                \ box.row_right,
                \ box.row_sep,
                \ cfg_opts.i_vertical,
                \ ]
    return table#util#AnyPattern(separators)
endfunction

function! s:GeneralHorizPattern() abort
    let box = table#config#Style(bufnr('%')).box_drawing
    let cfg_opts = table#config#Config(bufnr('%')).options
    let horizs = [
                \ box.align_horiz,
                \ box.sep_horiz,
                \ box.top_horiz,
                \ box.bottom_horiz,
                \ cfg_opts.i_horizontal,
                \ cfg_opts.i_alignment,
                \ ]
    return table#util#AnyPattern(horizs)
endfunction

function! s:GeneralSeparatorLinePattern() abort
    let box = table#config#Style(bufnr('%')).box_drawing
    let cfg_opts = table#config#Config(bufnr('%')).options
    let sep_line_chars = [
                \ box.align_left,
                \ box.align_right,
                \ box.align_sep,
                \ box.align_horiz,
                \ box.sep_left,
                \ box.sep_right,
                \ box.sep_sep,
                \ box.sep_horiz,
                \ box.top_left,
                \ box.top_right,
                \ box.top_sep,
                \ box.top_horiz,
                \ box.bottom_left,
                \ box.bottom_right,
                \ box.bottom_sep,
                \ box.bottom_horiz,
                \ cfg_opts.i_vertical,
                \ cfg_opts.i_horizontal,
                \ cfg_opts.i_alignment,
                \ ]
    let pattern = table#util#AnyPattern(sep_line_chars)
    let pattern = '\%(\s\|' .. pattern[3:]
    return pattern

    " let sep = s:GeneralSeparatorPattern()
    " let horiz = s:GeneralHorizPattern()
    " let cell = sep .. '\?\s\*' .. horiz .. '\+\s\*'
    " let pattern = '\%(' .. cell .. '\)\+' .. sep .. '\?'
    " return pattern
endfunction

function! s:CommentAwareTrim(line) abort
    let cs = table#util#CommentString(bufnr('%'))
    if empty(cs[0])
        return [a:line, '', '']
    endif
    let line = a:line

    let cs_pattern = '\V\^' .. table#util#CommentStringPattern(bufnr('%'))[0]
    let prefix = matchstrpos(line, cs_pattern)
    if prefix[1] != -1
        let line = strpart(line, prefix[2])
    endif

    let cs_pattern = '\V' .. table#util#CommentStringPattern(bufnr('%'))[1] .. '\$'
    let suffix = matchstrpos(line, cs_pattern)
    if suffix[1] != -1
        let line = strpart(line, 0, suffix[1])
    endif

    return [line, prefix, suffix]
endfunction

function! s:SplitPos(line) abort
    let pattern = '\V' .. s:GeneralSeparatorPattern()
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

function! s:HandleOmittedBorders(line, match_list, sep_pos_list) abort
    let style_opts = table#config#Style(bufnr('%')).options
    if !empty(a:sep_pos_list)
        if style_opts.omit_left_border
            call insert(a:match_list, strpart(a:line, 0, a:sep_pos_list[0][0]))
            call insert(a:sep_pos_list, [0, 0])
        endif
        if style_opts.omit_right_border
            call add(a:match_list, strpart(a:line, a:sep_pos_list[-1][1]))
            call add(a:sep_pos_list, [len(a:line), len(a:line)])
        endif
    endif
    return [a:match_list, a:sep_pos_list]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

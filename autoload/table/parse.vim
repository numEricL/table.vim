function! table#parse#IsTable(linenr) abort
    let line = getline(a:linenr)
    let prev = getline(a:linenr-1)
    let next = getline(a:linenr+1)

    if s:IsTableLine(line)
        if s:IsTableLine(prev) || s:IsIncompleteTableLine(prev)
            return v:true
        elseif s:IsTableLine(next) || s:IsIncompleteTableLine(next)
            return v:true
        endif
    elseif s:IsIncompleteTableLine(line)
        if s:IsTableLine(prev) || s:IsTableLine(next)
            return v:true
        endif
    endif
    return v:false
endfunction

function! table#parse#ParseLine(linenr) abort
    let line = getline(a:linenr)
    let [cells, sep_pos, seps] = s:SplitPos(line)
    let type = ''
    if !empty(cells)
        let type = s:LineType(cells, seps)
    else
        let [ sep_pos, type ] = s:ParseIncomplete(line, seps, sep_pos)
    endif
    let col_start = strdisplaywidth(strpart(line, 0, sep_pos[0][1]))
    return [ cells, col_start, sep_pos, type ]
endfunction

function! table#parse#FindTableRange(linenr) abort
    if !table#parse#IsTable(a:linenr)
        return [-1, -1]
    endif
    let top = a:linenr
    while table#parse#IsTable(top-1)
        let top -= 1
    endwhile
    let bottom = a:linenr
    while table#parse#IsTable(bottom+1)
        let bottom += 1
    endwhile
    return [top, bottom]
endfunction

function! s:IsTableLine(line) abort
    let cs = split(&commentstring, '%s')
    let cs_pattern = escape(trim(get(cs, 0, '')), '\')
    let cs_pattern = '\s\*\(' ..cs_pattern .. '\)\?\s\*'
    let is_table = v:false
    for type in [ 'row', 'separator', 'alignment','top', 'bottom' ]
        let [ left, right, sep, horiz ] = s:BoxDrawingPatterns(type)
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

function! s:IsIncompleteTableLine(line) abort
    let cs = split(&commentstring, '%s')
    let cs_pattern = escape(trim(get(cs, 0, '')), '\')
    let cs_pattern = '\s\*\(' ..cs_pattern .. '\)\?\s\*'
    for type in [ 'row', 'separator', 'top', 'bottom', 'alignment' ]
        let [ left, right, sep, horiz ] = table#config#GetBoxDrawingChars(type)
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

function! s:LineType(cells, separators) abort
    let type = 'row'

    let horiz = table#parse#GeneralHorizPattern()
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

function! s:ParseIncomplete(line, seps, sep_pos) abort
    let horiz = table#parse#GeneralHorizPattern()
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

function! s:BoxDrawingPatterns(type) abort
    let sep = table#config#GetBoxDrawingChars(a:type)
    for i in range(3)
        let sep[i] = table#util#AnyPattern([sep[i], g:i_separator])
    endfor
    if a:type ==# 'alignment'
        let sep[3] = table#util#AnyPattern([sep[i], g:i_dash, ':'])
    else
        let sep[3] = table#util#AnyPattern([sep[i], g:i_dash])
    endif
    return sep
endfunction

function! table#parse#GeneralSeparatorPattern() abort
    let separators = [
                \ table#config#Style().box_drawing.top_left,
                \ table#config#Style().box_drawing.top_right,
                \ table#config#Style().box_drawing.top_sep,
                \ table#config#Style().box_drawing.bottom_left,
                \ table#config#Style().box_drawing.bottom_right,
                \ table#config#Style().box_drawing.bottom_sep,
                \ table#config#Style().box_drawing.align_left,
                \ table#config#Style().box_drawing.align_right,
                \ table#config#Style().box_drawing.align_sep,
                \ table#config#Style().box_drawing.sep_left,
                \ table#config#Style().box_drawing.sep_right,
                \ table#config#Style().box_drawing.sep_sep,
                \ table#config#Style().box_drawing.row_left,
                \ table#config#Style().box_drawing.row_right,
                \ table#config#Style().box_drawing.row_sep,
                \ g:i_separator,
                \ ]
    return table#util#AnyPattern(separators)
endfunction

function! table#parse#GeneralHorizPattern() abort
    let horizs = [
                \ table#config#Style().box_drawing.top_horiz,
                \ table#config#Style().box_drawing.bottom_horiz,
                \ table#config#Style().box_drawing.align_horiz,
                \ table#config#Style().box_drawing.sep_horiz,
                \ g:i_dash,
                \ ]
    return table#util#AnyPattern(horizs)
endfunction

function! s:SplitPos(line) abort
    let pattern = table#parse#GeneralSeparatorPattern()
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

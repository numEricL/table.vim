let s:save_cpo = &cpo
set cpo&vim

function! table#util#AnyPattern(list) abort
    let unique = uniq(sort(a:list))
    call filter(unique, '!empty(v:val)')
    call map(unique, 'escape(v:val, "/\\")')
    let pattern = '\%(' .. unique[0]
    if len(unique) > 1
        for i in range(1, len(unique)-1)
            let pattern ..= '\|' .. unique[i]
        endfor
    endif
    let pattern ..= '\)'
    return pattern
endfunction

function! table#util#CommentString(bufnr) abort
    let cs = getbufvar(a:bufnr, '&commentstring')
    let cs_list = split(cs, '%s')
    call map(cs_list, 'trim(v:val)')
    return [get(cs_list, 0, ''), get(cs_list, 1, '')]
endfunction

function! table#util#CommentStringPattern(bufnr) abort
    let cs = table#util#CommentString(a:bufnr)
    for i in range(len(cs))
        if !empty(cs[i])
            let cs[i] = table#util#AnyPattern([cs[i]])
            let cs[i] = '\s\*' .. cs[i] .. '\?\s\*'
        else
            let cs[i] = '\s\*'
        endif
    endfor
    return cs
endfunction

function! table#util#SearchSorted(x, list) abort
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

function! table#util#Step2D(vec, xbounds, ybound, ...) abort
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

function! table#util#ComputeWidths(table) abort
    let widths = []
    for col in range(a:table.ColCount())
        let max_width = 0
        for row in a:table.rows
            let cell = get(row.cells, col, '')
            let max_width = max([max_width, s:CellStrDisplayWidth(cell)])
        endfor
        call add(widths, max_width)
    endfor
    return widths
endfunction

function! s:CellStrDisplayWidth(cell) abort
    let width = 0
    for line in a:cell
        let width = max([width, strdisplaywidth(line)])
    endfor
    return width
endfunction

function! table#util#Pad(string, length) abort
    let pad_len = a:length - strdisplaywidth(a:string)
    let pad = (pad_len > 0)? repeat(' ', pad_len) : ''
    return a:string .. pad
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

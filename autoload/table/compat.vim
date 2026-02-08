" compatibility for vim8 shipped with ubuntu 20.04

function! table#compat#getbufoneline(bufnr, lnum) abort
    if has('*getbufoneline')
        return getbufoneline(a:bufnr, a:lnum)
    else
        return getbufline(a:bufnr, a:lnum)[0]
    endi
endfunction

function! table#compat#trim(text, mask, dir) abort
    " NVIM v0.7.2 has a bug where trim with dir is defined but doesn't work
    if v:version >= 900
        return trim(a:text, a:mask, a:dir)
    else
        if a:dir == 0
            return trim(a:text, a:mask)
        elseif a:dir == 1
            return substitute(a:text, '^\_s*', '', '')
        elseif a:dir == 2
            return substitute(a:text, '\_s*$', '', '')
        endif
    endtry
endfunction

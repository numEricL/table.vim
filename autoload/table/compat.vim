let s:save_cpo = &cpo
set cpo&vim

" compatibility for vim8 shipped with ubuntu 20.04

function! table#compat#getbufoneline(bufnr, lnum) abort
    if exists('*getbufoneline')
        return getbufoneline(a:bufnr, a:lnum)
    else
        return getbufline(a:bufnr, a:lnum)[0]
    endif
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
    endif
endfunction

function! table#compat#virtcol2col(winid, lnum, col) abort
    if exists('*virtcol2col')
        return virtcol2col(a:winid, a:lnum, a:col)
    endif

    let bufnr = winbufnr(a:winid)
    let line = table#compat#getbufoneline(bufnr, a:lnum)
    " input col and output byte are 1-based, internal computations are 0-based
    return table#util#DisplayWidthToByteWidth(line, a:col-1) + 1
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

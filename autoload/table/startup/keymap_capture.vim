let s:cpo = &cpo
set cpo&vim

let s:noremap_dict = {}
let s:noremap_id = 0
let s:noremap_by_id = []

let s:namespace = "table#"

"is like mode in maparg(), but does not support ''
function! table#startup#keymap_capture#Capture(mode, map) abort
    if a:mode !~# '\v^[nvoxsilc]$'
        throw 'keymap_capture: Invalid mode ' .. a:mode
    endif
    if empty(maparg(a:map, a:mode, 0, 1))
        return s:CaptureNoremap(a:map)
    else
        return s:CaptureMap(a:mode, a:map)
    endif
endfunction

function! s:CaptureNoremap(map) abort
    if !has_key(s:noremap_dict, a:map)
        let plugmap  = '<plug>(' .. s:namespace .. 'noremap_' .. s:noremap_id .. ')'
        execute 'noremap  <silent> ' .. plugmap .. ' ' .. a:map
        execute 'noremap! <silent> ' .. plugmap .. ' ' .. a:map
        let s:noremap_dict[a:map] = plugmap
        call add(s:noremap_by_id, a:map)
        let s:noremap_id += 1
    endif
    return s:noremap_dict[a:map]
endfunction

function! s:CaptureMap(mode, map) abort
    let rhs_mapinfo = maparg(a:map, a:mode, 0, 1)
    let map_with_sentinel = substitute(a:map, ')', 'RPAREN', 'g')
    let plugmap = '<plug>(' .. s:namespace .. a:mode .. 'map_' .. map_with_sentinel .. ')'

    if empty(rhs_mapinfo)
        throw 'keymap_capture: No mapping found for ' .. a:map
    endif
    if get(rhs_mapinfo, 'rhs', '') =~# plugmap
        throw 'keymap_capture: Recursive mapping for ' .. a:map .. ' detected.'
    endif

    execute a:mode .. 'map ' .. plugmap .. ' <nop>'
    let new_mapinfo = maparg(plugmap, a:mode, 0, 1)
    for key in ['lhs', 'lhsraw', 'lhsrawalt', 'mode']
        if has_key(new_mapinfo, key)
            let rhs_mapinfo[key] = new_mapinfo[key]
        else
            silent! call remove(rhs_mapinfo, key)
        endif
    endfor
    try
        call mapset(rhs_mapinfo)
    catch /^Vim\%((\a\+)\)\=:E119:/
        call mapset(a:mode, 0, rhs_mapinfo)
    endtry
    return plugmap
endfunction

" [[untested]] Compatibility function for Vim versions without mapset()
" function! s:MapSet_COMPAT(dict) abort
"   let mode    = get(a:dict, 'mode', '')
"   let lhs     = get(a:dict, 'lhs', '')
"   let rhs     = get(a:dict, 'rhs', '')
"   let noremap = get(a:dict, 'noremap', v:false)
"   let silent  = get(a:dict, 'silent', v:false)
"   let expr    = get(a:dict, 'expr', v:false)
"   let unique  = get(a:dict, 'unique', v:false)
"   let buffer  = get(a:dict, 'buffer', v:false)
"
"   let cmd = mode
"   let cmd ..= noremap ? 'noremap'  : 'map'
"   let cmd ..= silent  ? '<silent>' : ''
"   let cmd ..= expr    ? '<expr>'   : ''
"   let cmd ..= unique  ? '<unique>' : ''
"   let cmd ..= buffer  ? '<buffer>' : ''
"   let cmd ..= ' ' .. lhs .. ' ' .. rhs
"   execute cmd
" endfunction

" " for logging/debugging
" function! s:NoremapInvertLookup(nr) abort
"     return get(s:noremap_by_id, a:nr, '')
" endfunction

let &cpo = s:cpo
unlet s:cpo

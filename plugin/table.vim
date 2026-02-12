let s:save_cpo = &cpo
set cpo&vim

command! -nargs=* -complete=customlist,table#commands#TableComplete Table call table#commands#TableCommand(<f-args>)
command! -nargs=* -complete=customlist,table#commands#TableOptionComplete TableOption call table#commands#TableOptionCommand(<f-args>)

" only defines <plug> mappings if g:table_disable_mappings is set
autocmd VimEnter * call table#startup#mappings#Setup()

if !exists('g:TableSortComparator')
    let g:TableSortComparator = ''
endif

let &cpo = s:save_cpo
unlet s:save_cpo

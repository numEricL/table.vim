command! -nargs=* -complete=customlist,table#commands#Complete Table call table#commands#TableCommand(<f-args>)

" only defines <plug> mappings if g:table_disable_mappings is set
autocmd VimEnter * call table#startup#mappings#Setup()

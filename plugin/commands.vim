command! -nargs=* -complete=customlist,table#commands#Complete Table call table#commands#TableCommand(<f-args>)

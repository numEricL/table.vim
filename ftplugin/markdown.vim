if exists('g:table_disable_ftplugins') && g:table_disable_ftplugins
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

call table#SetBufferConfig({'style': 'markdown'})

let &cpo = s:save_cpo
unlet s:save_cpo

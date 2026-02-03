if exists('g:table_disable_ftplugins') && g:table_disable_ftplugins
    finish
endif

call table#SetBufferConfig({'style': 'markdown'})

nnoremap <plug>(table_complete) :call table#Complete(line('.'))<CR>
nnoremap <plug>(table_align) :call table#Align(line('.'))<CR>

inoremap <silent> <plug>(table_next) <c-o><cmd>call table#NextCell('forward')<cr>
inoremap <silent> <plug>(table_prev) <c-o><cmd>call table#NextCell('backward')<cr>
nnoremap <silent> <plug>(table_next) <cmd>call table#NextCell('forward')<cr>
nnoremap <silent> <plug>(table_prev) <cmd>call table#NextCell('backward')<cr>
xnoremap <silent> <plug>(table_next) <cmd>call table#NextCell('forward')<cr>
xnoremap <silent> <plug>(table_prev) <cmd>call table#NextCell('backward')<cr>

" nnoremap <leader><bar> <plug>(table_complete)
" inoremap <bar> <bar><c-o><plug>(table_align) 
"
" nmap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
" nmap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"
" imap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
" imap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"

nnoremap <plug>(table_complete) :call table#Complete(line('.'))<CR>
nnoremap <plug>(table_align) :call table#Align(line('.'))<CR>

inoremap <silent> <plug>(table_next) <c-o><cmd>call table#NextCell('forward')<cr>
inoremap <silent> <plug>(table_prev) <c-o><cmd>call table#NextCell('backward')<cr>
nnoremap <silent> <plug>(table_next) <cmd>call table#NextCell('forward')<cr>
nnoremap <silent> <plug>(table_prev) <cmd>call table#NextCell('backward')<cr>
xnoremap <silent> <plug>(table_next) <cmd>call table#NextCell('forward')<cr>
xnoremap <silent> <plug>(table_prev) <cmd>call table#NextCell('backward')<cr>

xnoremap <silent> <plug>(table_cell_textobj)   <cmd>call textobj#Select(function('table#textobj#Cell'))<cr>
xnoremap <silent> <plug>(table_row_textobj)    <cmd>call textobj#Select(function('table#textobj#Row'))<cr>
xnoremap <silent> <plug>(table_column_textobj) <cmd>call textobj#Select(function('table#textobj#Column'))<cr>
onoremap <silent> <plug>(table_cell_textobj)   <cmd>call textobj#Select(function('table#textobj#Cell'))<cr>
onoremap <silent> <plug>(table_row_textobj)    <cmd>call textobj#Select(function('table#textobj#Row'))<cr>
onoremap <silent> <plug>(table_column_textobj) <cmd>call textobj#Select(function('table#textobj#Column'))<cr>

xnoremap tx <plug>(table_cell_textobj)
xnoremap tr <plug>(table_row_textobj)
xnoremap tc <plug>(table_column_textobj)
onoremap tx <plug>(table_cell_textobj)
onoremap tr <plug>(table_row_textobj)
onoremap tc <plug>(table_column_textobj)

" nnoremap <leader><bar> <plug>(table_complete)
" inoremap <bar> <bar><c-o><plug>(table_align) 
"
" nmap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
" nmap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"
" imap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
" imap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"

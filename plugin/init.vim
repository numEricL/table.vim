call table#style#fancy#Register()
" Table Style stars
Table Style markdown
" Table StyleOption omit_left_border 1
" Table StyleOption omit_right_border 1
Table Option multiline 1

"""
nnoremap <leader><leader> <plug>(table_align)
"""

nnoremap <leader><bar> <plug>(table_complete)
inoremap <bar> <bar><c-o><plug>(table_align)
nnoremap <leader>td <plug>(table_to_default)
nnoremap <leader>te <plug>(table_cell_edit)

nmap <expr> <tab> table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
xmap <expr> <tab> table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
imap <expr> <tab> table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"

nmap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"
xmap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"
imap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"

nmap <expr> <c-h> table#IsTable(line('.')) ? "\<plug>(table_move_left)"  : "\<c-h>"
nmap <expr> <c-l> table#IsTable(line('.')) ? "\<plug>(table_move_right)" : "\<c-l>"
nmap <expr> <c-k> table#IsTable(line('.')) ? "\<plug>(table_move_up)"    : "\<c-k>"
nmap <expr> <c-j> table#IsTable(line('.')) ? "\<plug>(table_move_down)"  : "\<c-j>"

xmap <expr> <c-h> table#IsTable(line('.')) ? "\<plug>(table_move_left)"  : "\<c-h>"
xmap <expr> <c-l> table#IsTable(line('.')) ? "\<plug>(table_move_right)" : "\<c-l>"
xmap <expr> <c-k> table#IsTable(line('.')) ? "\<plug>(table_move_up)"    : "\<c-k>"
xmap <expr> <c-j> table#IsTable(line('.')) ? "\<plug>(table_move_down)"  : "\<c-j>"

xnoremap tx <plug>(table_cell_textobj)
onoremap tx <plug>(table_cell_textobj)
xnoremap tr <plug>(table_row_textobj)
onoremap tr <plug>(table_row_textobj)
xnoremap tc <plug>(table_column_textobj)
onoremap tc <plug>(table_column_textobj)

xnoremap ix <plug>(table_inner_cell_textobj)
onoremap ix <plug>(table_inner_cell_textobj)
xnoremap ir <plug>(table_inner_row_textobj)
onoremap ir <plug>(table_inner_row_textobj)
xnoremap ic <plug>(table_inner_column_textobj)
onoremap ic <plug>(table_inner_column_textobj)

xnoremap ax <plug>(table_around_cell_textobj)
onoremap ax <plug>(table_around_cell_textobj)
xnoremap ar <plug>(table_around_row_textobj)
onoremap ar <plug>(table_around_row_textobj)
xnoremap ac <plug>(table_around_column_textobj)
onoremap ac <plug>(table_around_column_textobj)

Table Style markdown
" Table StyleOption omit_left_border 1
" Table StyleOption omit_right_border 1
" Table Option multiline_cells 1

"""
nnoremap <leader><leader> <plug>(table_align)
"""

nnoremap <leader><bar> <plug>(table_complete)
nnoremap <leader>td <plug>(table_to_default)
inoremap <bar> <bar><c-o><plug>(table_align)

nmap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
xmap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
imap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"

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

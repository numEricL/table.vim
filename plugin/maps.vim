" table drawing
nnoremap <plug>(table_complete) :call table#Complete(line('.'))<CR>
nnoremap <plug>(table_align) :call table#Align(line('.'))<CR>
nnoremap <plug>(table_to_default) :call table#ToDefault(line('.'))<CR>

" table navigation cycle
inoremap <silent> <plug>(table_next) <c-o><cmd>call table#CycleCursorCell('forward', v:count1)<cr>
inoremap <silent> <plug>(table_prev) <c-o><cmd>call table#CycleCursorCell('backward', v:count1)<cr>
nnoremap <silent> <plug>(table_next) <cmd>call table#CycleCursorCell('forward', v:count1)<cr>
nnoremap <silent> <plug>(table_prev) <cmd>call table#CycleCursorCell('backward', v:count1)<cr>
xnoremap <silent> <plug>(table_next) <cmd>call table#CycleCursorCell('forward', v:count1)<cr>
xnoremap <silent> <plug>(table_prev) <cmd>call table#CycleCursorCell('backward', v:count1)<cr>

" table navigation directional
inoremap <silent> <plug>(table_move_left)  <c-o><cmd>call table#MoveCursorCell('left', v:count1)<cr>
inoremap <silent> <plug>(table_move_right) <c-o><cmd>call table#MoveCursorCell('right', v:count1)<cr>
inoremap <silent> <plug>(table_move_up)    <c-o><cmd>call table#MoveCursorCell('up', v:count1)<cr>
inoremap <silent> <plug>(table_move_down)  <c-o><cmd>call table#MoveCursorCell('down', v:count1)<cr>
nnoremap <silent> <plug>(table_move_left)  <cmd>call table#MoveCursorCell('left', v:count1)<cr>
nnoremap <silent> <plug>(table_move_right) <cmd>call table#MoveCursorCell('right', v:count1)<cr>
nnoremap <silent> <plug>(table_move_up)    <cmd>call table#MoveCursorCell('up', v:count1)<cr>
nnoremap <silent> <plug>(table_move_down)  <cmd>call table#MoveCursorCell('down', v:count1)<cr>
xnoremap <silent> <plug>(table_move_left)  <cmd>call table#MoveCursorCell('left', v:count1)<cr>
xnoremap <silent> <plug>(table_move_right) <cmd>call table#MoveCursorCell('right', v:count1)<cr>
xnoremap <silent> <plug>(table_move_up)    <cmd>call table#MoveCursorCell('up', v:count1)<cr>
xnoremap <silent> <plug>(table_move_down)  <cmd>call table#MoveCursorCell('down', v:count1)<cr>

" table text objects
xnoremap <silent> <plug>(table_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'default')<cr>
onoremap <silent> <plug>(table_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'default')<cr>
xnoremap <silent> <plug>(table_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'default')<cr>
onoremap <silent> <plug>(table_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'default')<cr>
xnoremap <silent> <plug>(table_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'default')<cr>
onoremap <silent> <plug>(table_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'default')<cr>

" table inner text objects
xnoremap <silent> <plug>(table_inner_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'inner')<cr>
onoremap <silent> <plug>(table_inner_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'inner')<cr>
xnoremap <silent> <plug>(table_inner_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'inner')<cr>
onoremap <silent> <plug>(table_inner_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'inner')<cr>
xnoremap <silent> <plug>(table_inner_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'inner')<cr>
onoremap <silent> <plug>(table_inner_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'inner')<cr>

" table around text objects
xnoremap <silent> <plug>(table_around_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'around')<cr>
onoremap <silent> <plug>(table_around_cell_textobj)   <cmd>call table#textobj#Select(function('table#textobj#Cell'),   v:count1, 'around')<cr>
xnoremap <silent> <plug>(table_around_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'around')<cr>
onoremap <silent> <plug>(table_around_row_textobj)    <cmd>call table#textobj#Select(function('table#textobj#Row'),    v:count1, 'around')<cr>
xnoremap <silent> <plug>(table_around_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'around')<cr>
onoremap <silent> <plug>(table_around_column_textobj) <cmd>call table#textobj#Select(function('table#textobj#Column'), v:count1, 'around')<cr>

"
" suggested key mappings 
"
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

nnoremap <leader><bar> <plug>(table_complete)
inoremap <bar> <bar><c-o><plug>(table_align) 
nnoremap <leader>td <plug>(table_to_default)

nmap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
nmap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"
imap <expr> <tab>   table#IsTable(line('.')) ? "\<plug>(table_next)" : "\<tab>"
imap <expr> <s-tab> table#IsTable(line('.')) ? "\<plug>(table_prev)" : "\<s-tab>"

nmap <expr> <c-h> table#istable(line('.')) ? "\<plug>(table_move_left)"  : "\<c-h>"
nmap <expr> <c-l> table#istable(line('.')) ? "\<plug>(table_move_right)" : "\<c-l>"
nmap <expr> <c-k> table#istable(line('.')) ? "\<plug>(table_move_up)"    : "\<c-k>"
nmap <expr> <c-j> table#istable(line('.')) ? "\<plug>(table_move_down)"  : "\<c-j>"
xmap <expr> <c-h> table#istable(line('.')) ? "\<plug>(table_move_left)"  : "\<c-h>"
xmap <expr> <c-l> table#istable(line('.')) ? "\<plug>(table_move_right)" : "\<c-l>"
xmap <expr> <c-k> table#istable(line('.')) ? "\<plug>(table_move_up)"    : "\<c-k>"
xmap <expr> <c-j> table#istable(line('.')) ? "\<plug>(table_move_down)"  : "\<c-j>"

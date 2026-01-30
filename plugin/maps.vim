" table drawing
nnoremap <silent> <plug>(table_complete)   <cmd>call table#Complete(line('.'))<cr>
nnoremap <silent> <plug>(table_align)      <cmd>call table#Align(line('.'))<cr>
nnoremap <silent> <plug>(table_to_default) <cmd>call table#ToDefault(line('.'))<cr>
nnoremap <silent> <plug>(table_cell_edit)  <cmd>lua require('edit_cell').edit_cell_under_cursor()<cr>

" table navigation cycle
inoremap <silent> <plug>(table_next) <c-o><cmd>call table#CycleCursor('forward', v:count1)<cr>
inoremap <silent> <plug>(table_prev) <c-o><cmd>call table#CycleCursor('backward', v:count1)<cr>
nnoremap <silent> <plug>(table_next) <cmd>call table#CycleCursor('forward', v:count1)<cr>
nnoremap <silent> <plug>(table_prev) <cmd>call table#CycleCursor('backward', v:count1)<cr>
xnoremap <silent> <plug>(table_next) <cmd>call table#CycleCursor('forward', v:count1)<cr>
xnoremap <silent> <plug>(table_prev) <cmd>call table#CycleCursor('backward', v:count1)<cr>

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

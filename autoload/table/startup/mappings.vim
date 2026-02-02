let s:plugmaps_defined = 0

function! table#startup#mappings#Setup() abort
    if !exists('g:table_disable_mappings') || !g:table_disable_mappings
        call s:SetDefault()
    else
        call s:DefinePlugMaps()
    endif
endfunction

function! s:SetDefault() abort
    call s:DefinePlugMaps()
    " Table operations
    inoremap <bar>         <bar><c-o><plug>(table_align)
    nnoremap <leader><bar> <plug>(table_complete)
    nnoremap <leader>ta    <plug>(table_align)
    nnoremap <leader>td    <plug>(table_to_default)

    if has('nvim')
        nnoremap <leader>te <plug>(table_cell_edit)
    endif

    " Navigation with context-aware mappings
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

    " Text objects
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
endfunction

function! s:DefinePlugMaps() abort
    if s:plugmaps_defined
        return
    endif
    let s:plugmaps_defined = 1

    " table drawing
    nnoremap <silent> <plug>(table_complete)   <cmd>call table#Complete(line('.'))<cr>
    nnoremap <silent> <plug>(table_align)      <cmd>call table#Align(line('.'))<cr>
    nnoremap <silent> <plug>(table_to_default) <cmd>call table#ToDefault(line('.'))<cr>
    nnoremap <silent> <plug>(table_cell_edit)  <cmd>lua require('table_vim.cell_editor').edit_at_cursor()<cr>

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
endfunction

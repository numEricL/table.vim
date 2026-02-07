let s:save_cpo = &cpo
set cpo&vim

let s:plugmaps_defined = 0

function! table#startup#mappings#Setup() abort
    call s:DefinePlugMaps()
    if !exists('g:table_disable_mappings') || !g:table_disable_mappings
        call s:SetDefault()
    endif
endfunction

function s:SetContextAwareMap(modes, lhs, rhs) abort
    for mode in a:modes
        let usermap = table#startup#keymap_capture#Capture(mode, a:lhs)
        execute mode .. 'map <expr> ' .. a:lhs .. ' table#IsTable(line(".")) ? "' .. a:rhs .. '" : "' .. usermap .. '"'
    endfor
endfunction

function! s:SetDefault() abort
    " Auto-align on pipe
    call s:SetContextAwareMap(['i'], '<bar>', "<bar><c-o><plug>(table_align)")

    " Navigation with context-aware mappings
    call s:SetContextAwareMap(['n', 'x'], '<tab>',   '<plug>(table_next)')
    call s:SetContextAwareMap(['n', 'x'], '<s-tab>', '<plug>(table_prev)')
    call s:SetContextAwareMap(['n', 'x'], '<c-h>',   '<plug>(table_move_left)')
    call s:SetContextAwareMap(['n', 'x'], '<c-l>',   '<plug>(table_move_right)')
    call s:SetContextAwareMap(['n', 'x'], '<c-k>',   '<plug>(table_move_up)')
    call s:SetContextAwareMap(['n', 'x'], '<c-j>',   '<plug>(table_move_down)')

    " Text objects
    call s:SetContextAwareMap(['x', 'o'], 'tx', '<plug>(table_cell_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'ix', '<plug>(table_inner_cell_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'ax', '<plug>(table_around_cell_textobj)')

    call s:SetContextAwareMap(['x', 'o'], 'tr', '<plug>(table_row_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'ir', '<plug>(table_inner_row_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'ar', '<plug>(table_around_row_textobj)')

    call s:SetContextAwareMap(['x', 'o'], 'ic', '<plug>(table_inner_column_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'tc', '<plug>(table_column_textobj)')
    call s:SetContextAwareMap(['x', 'o'], 'ac', '<plug>(table_around_column_textobj)')
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
    nnoremap <silent> <plug>(table_cell_edit)  <cmd>call table#CellEditor()<cr>

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

let &cpo = s:save_cpo
unlet s:save_cpo

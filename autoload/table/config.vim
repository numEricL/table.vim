if !exists('g:config')
    let g:config = { 'style' : 'markdown' }
endif

let g:t = { 'valid': v:false }
let g:i_separator = '|'
let g:i_dash = '-'
let g:default_alignment = 'l'
let g:multiline_cells_enable = v:false
let g:multiline_cells_presever_indentation = v:false

function! table#config#Style() abort
    return table#style#Get(g:config.style)
endfunction

function! table#config#GetBoxDrawingChars(type) abort
    let box_drawing = table#config#Style().box_drawing
    if a:type == 'top'
        let left  = box_drawing.top_left
        let right = box_drawing.top_right
        let sep   = box_drawing.top_sep
        let horiz = box_drawing.top_horiz
    elseif a:type == 'bottom'
        let left  = box_drawing.bottom_left
        let right = box_drawing.bottom_right
        let sep   = box_drawing.bottom_sep
        let horiz = box_drawing.bottom_horiz
    elseif a:type == 'alignment'
        let left  = box_drawing.align_left
        let right = box_drawing.align_right
        let sep   = box_drawing.align_sep
        let horiz = box_drawing.align_horiz
    elseif a:type == 'separator'
        let left  = box_drawing.sep_left
        let right = box_drawing.sep_right
        let sep   = box_drawing.sep_sep
        let horiz = box_drawing.sep_horiz
    elseif a:type == 'row'
        let left  = box_drawing.row_left
        let right = box_drawing.row_right
        let sep   = box_drawing.row_sep
        let horiz = ''
    else
        throw 'unknown separator type: ' .. a:type
    endif
    let left = table#config#Style().omit_left_border ? '' : left
    let right = table#config#Style().omit_right_border ? '' : right
    return [left, right, sep, horiz]
endfunction

" supported styles: markdown, orgmode, simple_full, single_full, double_full,
" double_single, ribbed

let s:styles = {}

function table#style#Get(style) abort
    if !has_key(s:styles, a:style)
        throw 'Style "' . a:style . '" is not registered.'
    endif
    return s:styles[a:style]
endfunction

function table#style#Exists(style) abort
    return a:style ==# 'default' || has_key(s:styles, a:style)
endfunction

function table#style#GetStyleNames() abort
    return keys(s:styles)
endfunction

function table#style#Register(style_name, style_def) abort
    let s:styles[a:style_name] = a:style_def
endfunction

let s:styles.markdown = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:true,
            \   'omit_bottom_border'   : v:true,
            \   'omit_separator_rows'  : v:true,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '',
            \   'top_right'    : '',
            \   'top_sep'      : '',
            \   'top_horiz'    : '',
            \   'bottom_left'  : '',
            \   'bottom_right' : '',
            \   'bottom_sep'   : '',
            \   'bottom_horiz' : '',
            \   'align_left'   : '|',
            \   'align_right'  : '|',
            \   'align_sep'    : '|',
            \   'align_horiz'  : '-',
            \   'sep_left'     : '|',
            \   'sep_right'    : '|',
            \   'sep_sep'      : '|',
            \   'sep_horiz'    : '-',
            \   'row_left'     : '|',
            \   'row_right'    : '|',
            \   'row_sep'      : '|',
            \   }
            \ }

let s:styles.orgmode = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:true,
            \   'omit_bottom_border'   : v:true,
            \   'omit_separator_rows'  : v:true,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '',
            \   'top_right'    : '',
            \   'top_sep'      : '',
            \   'top_horiz'    : '',
            \   'bottom_left'  : '',
            \   'bottom_right' : '',
            \   'bottom_sep'   : '',
            \   'bottom_horiz' : '',
            \   'align_left'   : '|',
            \   'align_right'  : '|',
            \   'align_sep'    : '|',
            \   'align_horiz'  : '-',
            \   'sep_left'     : '|',
            \   'sep_right'    : '|',
            \   'sep_sep'      : '|',
            \   'sep_horiz'    : '-',
            \   'row_left'     : '|',
            \   'row_right'    : '|',
            \   'row_sep'      : '|',
            \   }
            \ }

let s:styles.simple_full = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '|',
            \   'top_right'    : '|',
            \   'top_sep'      : '|',
            \   'top_horiz'    : '-',
            \   'bottom_left'  : '|',
            \   'bottom_right' : '|',
            \   'bottom_sep'   : '|',
            \   'bottom_horiz' : '-',
            \   'align_left'   : '|',
            \   'align_right'  : '|',
            \   'align_sep'    : '|',
            \   'align_horiz'  : '-',
            \   'sep_left'     : '|',
            \   'sep_right'    : '|',
            \   'sep_sep'      : '|',
            \   'sep_horiz'    : '-',
            \   'row_left'     : '|',
            \   'row_right'    : '|',
            \   'row_sep'      : '|',
            \   }
            \ }

let s:styles.single_full = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '┌',
            \   'top_right'    : '┐',
            \   'top_sep'      : '┬',
            \   'top_horiz'    : '─',
            \   'bottom_left'  : '└',
            \   'bottom_right' : '┘',
            \   'bottom_sep'   : '┴',
            \   'bottom_horiz' : '─',
            \   'align_left'   : '├',
            \   'align_right'  : '┤',
            \   'align_sep'    : '┼',
            \   'align_horiz'  : '─',
            \   'sep_left'     : '├',
            \   'sep_right'    : '┤',
            \   'sep_sep'      : '┼',
            \   'sep_horiz'    : '─',
            \   'row_left'     : '│',
            \   'row_right'    : '│',
            \   'row_sep'      : '│',
            \   }
            \ }

let s:styles.double_full = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '╔',
            \   'top_right'    : '╗',
            \   'top_sep'      : '╦',
            \   'top_horiz'    : '═',
            \   'bottom_left'  : '╚',
            \   'bottom_right' : '╝',
            \   'bottom_sep'   : '╩',
            \   'bottom_horiz' : '═',
            \   'align_left'   : '╠',
            \   'align_right'  : '╣',
            \   'align_sep'    : '╬',
            \   'align_horiz'  : '═',
            \   'sep_left'     : '╠',
            \   'sep_right'    : '╣',
            \   'sep_sep'      : '╬',
            \   'sep_horiz'    : '═',
            \   'row_left'     : '║',
            \   'row_right'    : '║',
            \   'row_sep'      : '║',
            \   }
            \ }

let s:styles.double_single = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '╔',
            \   'top_right'    : '╗',
            \   'top_sep'      : '╤',
            \   'top_horiz'    : '═',
            \   'bottom_left'  : '╚',
            \   'bottom_right' : '╝',
            \   'bottom_sep'   : '╧',
            \   'bottom_horiz' : '═',
            \   'align_left'   : '╟',
            \   'align_right'  : '╢',
            \   'align_sep'    : '┼',
            \   'align_horiz'  : '─',
            \   'sep_left'     : '╟',
            \   'sep_right'    : '╢',
            \   'sep_sep'      : '┼',
            \   'sep_horiz'    : '─',
            \   'row_left'     : '║',
            \   'row_right'    : '║',
            \   'row_sep'      : '│',
            \   }
            \ }

let s:styles.ribbed = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'top_left'     : '╔',
            \   'top_right'    : '╗',
            \   'top_sep'      : '╦',
            \   'top_horiz'    : '─',
            \   'bottom_left'  : '╚',
            \   'bottom_right' : '╝',
            \   'bottom_sep'   : '╩',
            \   'bottom_horiz' : '─',
            \   'align_left'   : '╠',
            \   'align_right'  : '╣',
            \   'align_sep'    : '╬',
            \   'align_horiz'  : '─',
            \   'sep_left'     : '╠',
            \   'sep_right'    : '╣',
            \   'sep_sep'      : '╬',
            \   'sep_horiz'    : '─',
            \   'row_left'     : '│',
            \   'row_right'    : '│',
            \   'row_sep'      : '│',
            \   }
            \ }

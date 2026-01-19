let s:table_default_config = {
            \ 'style': 'default',
            \ 'options': {
            \   'i_vertical': '|',
            \   'i_horizontal': '-',
            \   'default_alignment': 'l',
            \   'multiline_cells': v:true,
            \   'multiline_preserve_indentation': v:true,
            \ },
            \ }

let s:config = deepcopy(s:table_default_config)

function! table#config#Config() abort
    return s:config
endfunction

function! table#config#Style() abort
    return table#style#Get(s:config.style)
endfunction

function! s:ValidateConfig(config) abort
    for key in keys(a:config)
        if !has_key(s:table_default_config, key)
            throw 'Invalid configuration key: ' .. key
        endif
        if key ==# 'options'
            for opt_key in keys(a:config.options)
                if !has_key(s:table_default_config.options, opt_key)
                    throw 'Invalid configuration option key: ' .. opt_key
                endif
            endfor
        elseif key ==# 'style' && a:config.style !=# 'default'
            if !table#style#Exists(a:config.style)
                throw 'Style "' . a:config.style . '" is not registered.'
            endif
        endif
    endfor
endfunction

function! table#config#SetConfig(config) abort
    call s:ValidateConfig(a:config)
    if has_key(a:config, 'options')
        call extend(s:config.options, a:config.options)
    endif
    if has_key(a:config, 'style')
        if a:config.style ==# 'default' && !table#style#Exists('default')
            call table#style#Register('default', s:GeneratreDefaultStyle())
        endif
        let s:config.style = a:config.style
    endif
endfunction

function! table#config#RestoreDefault() abort
    call table#config#SetConfig(s:table_default_config)
endfunction

function! s:GeneratreDefaultStyle() abort
    let vert  = table#config#Config().options.i_vertical
    let horiz = table#config#Config().options.i_horizontal
    let style = {
                \ 'options' : {
                \   'omit_left_border'     : v:false,
                \   'omit_right_border'    : v:false,
                \   'omit_top_border'      : v:false,
                \   'omit_bottom_border'   : v:false,
                \   'omit_separator_rows'  : v:false,
                \ },
                \ 'box_drawing' : {
                \   'top_left'     : vert,
                \   'top_right'    : vert,
                \   'top_sep'      : vert,
                \   'top_horiz'    : horiz,
                \   'bottom_left'  : vert,
                \   'bottom_right' : vert,
                \   'bottom_sep'   : vert,
                \   'bottom_horiz' : horiz,
                \   'align_left'   : vert,
                \   'align_right'  : vert,
                \   'align_sep'    : vert,
                \   'align_horiz'  : horiz,
                \   'sep_left'     : vert,
                \   'sep_right'    : vert,
                \   'sep_sep'      : vert,
                \   'sep_horiz'    : horiz,
                \   'row_left'     : vert,
                \   'row_right'    : vert,
                \   'row_sep'      : vert,
                \   }
                \ }
    return style
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
    let left = table#config#Style().options.omit_left_border ? '' : left
    let right = table#config#Style().options.omit_right_border ? '' : right
    return [left, right, sep, horiz]
endfunction

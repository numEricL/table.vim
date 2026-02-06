let s:save_cpo = &cpo
set cpo&vim

let s:default_config = {
            \ 'disable_mappings'  : v:false,
            \ 'disable_ftplugins' : v:false,
            \ 'style': 'default',
            \ 'options': {
            \   'multiline'            : v:false,
            \   'preserve_indentation' : v:true,
            \   'default_alignment'    : 'left',
            \   'chunk_size'           : [-10, 10],
            \   'i_vertical'           : '|',
            \   'i_horizontal'         : '-',
            \   'i_alignment'          : ':',
            \ },
            \ 'style_options': {},
            \ }

let s:user_defaults = deepcopy(s:default_config)

function! s:InitBufferConfig(bufnr) abort
    if getbufvar(a:bufnr, 'table_config', v:null) is v:null
        call setbufvar(a:bufnr, 'table_config', deepcopy(s:user_defaults))
    endif
    if getbufvar(a:bufnr, 'table_style', v:null) is v:null
        call setbufvar(a:bufnr, 'table_style', {})
    endif
endfunction

function! table#config#Setup(config) abort
    call s:ValidateConfig(a:config)
    if has_key(a:config, 'disable_mappings')
        let g:table_disable_mappings = a:config.disable_mappings
    endif
    if has_key(a:config, 'disable_ftplugins')
        let g:table_disable_ftplugins = a:config.disable_ftplugins
    endif
    if has_key(a:config, 'options')
        call extend(s:user_defaults.options, a:config.options)
    endif
    if has_key(a:config, 'style')
        let s:user_defaults.style = a:config.style
    endif
    if has_key(a:config, 'style_options')
        call extend(s:user_defaults.style_options, a:config.style_options)
    endif
endfunction

function! table#config#SetBufferConfig(bufnr, config) abort
    call s:InitBufferConfig(a:bufnr)
    call s:ValidateConfig(a:config)
    if has_key(a:config, 'options')
        let cfg = getbufvar(a:bufnr, 'table_config')
        call extend(cfg.options, a:config.options)
        call setbufvar(a:bufnr, 'table_config', cfg)
    endif
    if has_key(a:config, 'style')
        let cfg = getbufvar(a:bufnr, 'table_config')
        let cfg.style = a:config.style
        let cfg.style_options = {}
        call setbufvar(a:bufnr, 'table_config', cfg)
        call setbufvar(a:bufnr, 'table_style', {})
    endif
    if has_key(a:config, 'style_options')
        let style = table#config#Style(a:bufnr)
        call extend(style.options, a:config.style_options)
        call setbufvar(a:bufnr, 'table_style', style)
    endif
    call table#table#InvalidateCache()
endfunction

function! table#config#Config(bufnr) abort
    call s:InitBufferConfig(a:bufnr)
    return deepcopy(getbufvar(a:bufnr, 'table_config'))
endfunction

function! table#config#Style(bufnr) abort
    call s:InitBufferConfig(a:bufnr)
    let style = getbufvar(a:bufnr, 'table_style')
    if empty(style)
        let cfg = getbufvar(a:bufnr, 'table_config')
        if cfg.style ==# 'default' && !table#style#Exists('default')
            call table#style#Register('default', s:GenerateDefaultStyle(a:bufnr))
        endif
        let style = deepcopy(table#style#Get(cfg.style))
        if !empty(cfg.style_options)
            call extend(style.options, cfg.style_options)
        endif
        call setbufvar(a:bufnr, 'table_style', style)
    endif
    return style
endfunction

function! table#config#SetStyle(bufnr, style_dict) abort
    call s:InitBufferConfig(a:bufnr)
    call setbufvar(a:bufnr, 'table_style', deepcopy(a:style_dict))
    call table#table#InvalidateCache()
endfunction

function! table#config#RestoreDefault(bufnr) abort
    call setbufvar(a:bufnr, 'table_config', deepcopy(s:default_config))
    call setbufvar(a:bufnr, 'table_style', {})
    call table#table#InvalidateCache()
endfunction

function! s:ValidateConfig(config) abort
    for key in keys(a:config)
        if !has_key(s:default_config, key)
            throw 'Invalid configuration key: ' .. key
        endif
        if key ==# 'options'
            for opt_key in keys(a:config.options)
                if !has_key(s:default_config.options, opt_key)
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

function! s:GenerateDefaultStyle(bufnr) abort
    call s:InitBufferConfig(a:bufnr)
    let cfg = table#config#Config(a:bufnr)
    let vert  = cfg.options.i_vertical
    let horiz = cfg.options.i_horizontal
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

function! table#config#GetBoxDrawingChars(bufnr, type) abort
    let box_drawing = table#config#Style(a:bufnr).box_drawing
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
    let style = table#config#Style(a:bufnr)
    let left = style.options.omit_left_border ? '' : left
    let right = style.options.omit_right_border ? '' : right
    return [left, right, sep, horiz]
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

" :Table command - for actions
function! table#commands#TableCommand(...) abort
    if a:0 == 0
        let actions = ['Align', 'Complete', 'EditCell', 'ToDefault', 'ToStyle']
        echomsg 'Table actions: ' .. join(actions, ', ')
        return
    endif

    let action = a:1
    let args = a:000[1:]

    if action ==# 'EditCell'
        if has('nvim')
            lua require('table_vim.cell_editor').edit_at_cursor()
        else
            call table#cell_editor#EditAtCursor()
        endif
    elseif action ==# 'Complete'
        call table#Complete(line('.'))
    elseif action ==# 'Align'
        call table#Align(line('.'))
    elseif action ==# 'ToDefault'
        call table#ToDefault(line('.'))
    elseif action ==# 'ToStyle'
        if len(args) == 0
            echohl ErrorMsg
            echomsg 'ToStyle: style name required'
            echohl None
            return
        endif
        call table#ToStyle(line('.'), args[0])
    else
        echohl ErrorMsg
        echomsg "Table: unknown action '" .. action .. "'"
        echohl None
    endif
endfunction

function! table#commands#TableComplete(ArgLead, CmdLine, CursorPos) abort
    let parts = split(a:CmdLine, '\s\+', 1)
    let num_args = len(parts) - 1

    " Complete action names
    if num_args <= 1
        let actions = ['Align', 'Complete', 'EditCell', 'ToDefault', 'ToStyle']
        return filter(copy(actions), 'v:val =~? "^" .. a:ArgLead')
    endif

    " Complete style names for ToStyle
    if num_args == 2 && len(parts) > 1 && parts[1] ==# 'ToStyle'
        let styles = ['default'] + table#style#GetNames()
        return filter(copy(styles), 'v:val =~? "^" .. a:ArgLead')
    endif

    return []
endfunction

" :TableOption command - for configuration
function! table#commands#TableOptionCommand(...) abort
    if a:0 == 0
        let subcommands = ['Option', 'StyleOption', 'Style', 'RegisterStyle']
        echomsg 'TableOption subcommands: ' .. join(subcommands, ', ')
        echomsg ' '
        echomsg "Current Style = " .. table#config#Config(bufnr('%')).style
        echomsg ' '
        call s:ShowOption([])
        echomsg ' '
        call s:ShowStyleOption([])
        return
    endif

    let subcommand = a:1
    let args = a:000[1:]

    if subcommand ==? 'Option'
        call s:SetOption(args)
    elseif subcommand ==? 'StyleOption'
        call s:SetStyleOption(args)
    elseif subcommand ==? 'Style'
        call s:SetStyle(args)
    elseif subcommand ==? 'RegisterStyle'
        call s:RegisterStyle(args)
    else
        echohl ErrorMsg
        echomsg "TableOption: unknown subcommand '" .. subcommand .. "'"
        echohl None
    endif
endfunction

function! table#commands#TableOptionComplete(ArgLead, CmdLine, CursorPos) abort
    let parts = split(a:CmdLine, '\s\+', 1)
    let num_args = len(parts) - 1

    " Complete subcommand names
    if num_args <= 1
        let subcommands = ['Option', 'StyleOption', 'Style', 'RegisterStyle']
        return filter(copy(subcommands), 'v:val =~? "^" .. a:ArgLead')
    endif

    " Delegate to appropriate completion function
    let subcommand = parts[1]
    let fake_cmdline = join([subcommand] + parts[2:], ' ')
    if subcommand ==? 'Option'
        return s:CompleteOption(a:ArgLead, fake_cmdline, a:CursorPos)
    elseif subcommand ==? 'Style'
        return s:CompleteStyle(a:ArgLead, fake_cmdline, a:CursorPos)
    elseif subcommand ==? 'StyleOption'
        return s:CompleteStyleOption(a:ArgLead, fake_cmdline, a:CursorPos)
    endif

    return []
endfunction

function! s:ConvertValue(value) abort
    if a:value ==? 'v:true' || a:value ==? 'true' || a:value ==# '1'
        return v:true
    elseif a:value ==? 'v:false' || a:value ==? 'false' || a:value ==# '0'
        return v:false
    elseif a:value =~# '^\d\+$'
        return str2nr(a:value)
    else
        return a:value
    endif
endfunction

function! s:SetOption(args) abort
    let bufnr = bufnr('%')
    let cfg_opts = table#config#Config(bufnr).options
    if len(a:args) == 0
        call s:ShowOption(a:args)
        return
    endif
    let key = a:args[0]
    if len(a:args) == 1
        echo key .. ' = ' .. string(cfg_opts[key])
        return
    endif
    let value = s:ConvertValue(a:args[1])
    call table#config#SetBufferConfig(bufnr, { 'options': { key : value } })
endfunction

function! s:ShowOption(args) abort
    let cfg_opts = table#config#Config(bufnr('%')).options
    echomsg "Table Options:"
    let maxlen = max(map(keys(cfg_opts), 'len(v:val)'))
    let sorted_items = sort(items(cfg_opts), {a, b -> a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0})
    for [key, value] in sorted_items
        let padded_key = table#util#Pad(key, maxlen)
        echomsg '  ' .. padded_key .. ' = ' .. string(value)
    endfor
endfunction

function! s:SetStyle(args) abort
    let bufnr = bufnr('%')
    if len(a:args) == 0
        echo 'Current style: ' .. table#config#Config(bufnr).style
        let styles = ['default'] + table#style#GetNames()
        echo 'Available styles: ' .. join(styles, ', ')
        return
    endif
    call table#config#SetBufferConfig(bufnr, { 'style': a:args[0] })
endfunction

function! s:RegisterStyle(args) abort
    let bufnr = bufnr('%')
    if len(a:args) == 0
        echohl ErrorMsg
        echomsg 'RegisterStyle: style name required'
        echohl None
        return
    endif
    let style_name = a:args[0]
    let current_style = deepcopy(table#config#Style(bufnr))
    call table#style#Register(style_name, current_style)
    call table#config#SetBufferConfig(bufnr, { 'style': style_name })
    echomsg 'Registered style "' .. style_name .. '"'
endfunction

function! s:SetStyleOption(args) abort
    let bufnr = bufnr('%')
    let style_opts = table#config#Style(bufnr).options
    if len(a:args) == 0
        call s:ShowStyleOption(a:args)
        return
    endif
    let key = a:args[0]
    if len(a:args) == 1
        echo key .. ' = ' .. string(style_opts[key])
        return
    endif
    let value = s:ConvertValue(a:args[1])
    call table#config#SetBufferConfig(bufnr, { 'style_options': { key : value } })
endfunction

function! s:ShowStyleOption(args) abort
    let style_opts = table#config#Style(bufnr('%')).options
    echomsg "Table StyleOptions:"
    let maxlen = max(map(keys(style_opts), 'len(v:val)'))
    let sorted_items = sort(items(style_opts), {a, b -> a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0})
    for [key, value] in sorted_items
        let padded_key = table#util#Pad(key, maxlen)
        echomsg '  ' .. padded_key .. ' = ' .. string(value)
    endfor
endfunction

function! s:CompleteOption(ArgLead, CmdLine, CursorPos) abort
    let options = keys(table#config#Config(bufnr('%')).options)
    let parts = split(a:CmdLine, '\s\+')
    let num_args = len(parts) - 1

    if num_args == 1 || (num_args == 0 && a:CmdLine =~# '\s$')
        return filter(copy(options), 'v:val =~? "^" .. a:ArgLead')
    elseif num_args == 2
        let option_key = parts[1]
        if option_key ==# 'default_alignment'
            return filter(['left', 'center', 'right'], 'v:val =~? "^" .. a:ArgLead')
        elseif option_key =~# 'enable\|indentation'
            return filter(['v:true', 'v:false'], 'v:val =~? "^" .. a:ArgLead')
        endif
    endif
    return []
endfunction

function! s:CompleteStyle(ArgLead, CmdLine, CursorPos) abort
    let styles = ['default'] + table#style#GetNames()
    return filter(copy(styles), 'v:val =~? "^" .. a:ArgLead')
endfunction

function! s:CompleteStyleOption(ArgLead, CmdLine, CursorPos) abort
    let style = table#config#Style(bufnr('%'))
    let parts = split(a:CmdLine, '\s\+')
    let num_args = len(parts) - 1

    if num_args == 1 || (num_args == 0 && a:CmdLine =~# '\s$')
        let keys_list = keys(style.options)
        return filter(copy(keys_list), 'v:val =~? "^" .. a:ArgLead')
    elseif num_args == 2
        let key = parts[1]
        if key =~# '^omit_'
            return filter(['v:true', 'v:false'], 'v:val =~? "^" .. a:ArgLead')
        endif
    endif
    return []
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

function! table#commands#TableCommand(...) abort
    if a:0 == 0
        echohl ErrorMsg
        echom "Table: subcommand required (SetOption, SetStyleOption, SetStyle)"
        echohl None
        return
    endif

    let subcommand = a:1
    let args = a:000[1:]

    if subcommand ==# 'SetOption'
        call s:SetTableOption(args)
    elseif subcommand ==# 'SetStyleOption'
        call s:SetTableStyleOption(args)
    elseif subcommand ==# 'SetStyle'
        call s:SetStyle(args)
    else
        echohl ErrorMsg
        echom "Table: unknown subcommand '" .. subcommand .. "'"
        echohl None
    endif
endfunction

function! table#commands#Complete(ArgLead, CmdLine, CursorPos) abort
    let parts = split(a:CmdLine, '\s\+', 1)
    let num_args = len(parts) - 1

    " If no args yet or completing the first arg (subcommand)
    if num_args <= 1
        " Complete subcommand names
        let subcommands = ['SetOption', 'SetStyleOption', 'SetStyle']
        return filter(copy(subcommands), 'v:val =~? "^" .. a:ArgLead')
    endif

    let subcommand = parts[1]

    if subcommand ==# 'SetOption'
        " Delegate to SetOption completion
        let fake_cmdline = 'TableOption ' .. join(parts[2:], ' ')
        let fake_pos = a:CursorPos - (len(subcommand) + 1 - len('TableOption'))
        return s:CompleteTableOption(a:ArgLead, fake_cmdline, fake_pos)
    elseif subcommand ==# 'SetStyle'
        " Delegate to SetStyle completion
        let fake_cmdline = 'TableStyle ' .. join(parts[2:], ' ')
        let fake_pos = a:CursorPos - (len(subcommand) + 1 - len('TableStyle'))
        return s:CompleteTableStyle(a:ArgLead, fake_cmdline, fake_pos)
    elseif subcommand ==# 'SetStyleOption'
        " Delegate to SetStyleOption completion
        let fake_cmdline = 'TableStyleOption ' .. join(parts[2:], ' ')
        let fake_pos = a:CursorPos - (len(subcommand) + 1 - len('TableStyleOption'))
        return s:CompleteTableStyleOption(a:ArgLead, fake_cmdline, fake_pos)
    endif

    return []
endfunction


function! s:SetTableOption(args) abort
    let cfg_opts = table#config#Config().options
    if len(a:args) == 0
        echom "Table Options:"
        let maxlen = max(map(keys(cfg_opts), 'len(v:val)'))
        let sorted_items = sort(items(cfg_opts), {a, b -> a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0})
        for [key, value] in sorted_items
            let padded_key = table#util#Pad(key, maxlen)
            echom '  ' .. padded_key .. ' = ' .. string(value)
        endfor
        return
    endif
    let key = a:args[0]
    if len(a:args) == 1
        echo key .. ' = ' .. string(cfg_opts[key])
        return
    endif
    let value = a:args[1]
    call table#config#SetConfig({ 'options': { key : value } })
endfunction

function! s:SetStyle(args) abort
    if len(a:args) == 0
        echo 'Current style: ' .. table#config#Config().style
        return
    endif
    call table#config#SetConfig({ 'style': a:args[0] })
endfunction

function! s:SetTableStyleOption(args) abort
    let style_opts = table#config#Style().options
    if len(a:args) == 0
        echom "Table Style Options:"
        let maxlen = max(map(keys(style_opts), 'len(v:val)'))
        let sorted_items = sort(items(style_opts), {a, b -> a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0})
        for [key, value] in sorted_items
            let padded_key = table#util#Pad(key, maxlen)
            echom '  ' .. padded_key .. ' = ' .. string(value)
        endfor
        return
    endif
    let key = a:args[0]
    if len(a:args) == 1
        echo key .. ' = ' .. string(style_opts[key])
        return
    endif
    let value = a:args[1]
    let style_opts[key] = value
endfunction

function! s:CompleteTableOption(ArgLead, CmdLine, CursorPos) abort
    let options = keys(table#config#Config().options)
    let parts = split(a:CmdLine, '\s\+')
    let num_args = len(parts) - 1

    if num_args == 1 || (num_args == 0 && a:CmdLine =~# '\s$')
        return filter(copy(options), 'v:val =~? "^" .. a:ArgLead')
    elseif num_args == 2
        let option_key = parts[1]
        if option_key ==# 'default_alignment'
            return filter(['l', 'c', 'r'], 'v:val =~? "^" .. a:ArgLead')
        elseif option_key =~# 'enable\|indentation'
            return filter(['v:true', 'v:false'], 'v:val =~? "^" .. a:ArgLead')
        endif
    endif
    return []
endfunction

function! s:CompleteTableStyle(ArgLead, CmdLine, CursorPos) abort
    let styles = ['default'] + table#style#GetStyleNames()
    return filter(copy(styles), 'v:val =~? "^" .. a:ArgLead')
endfunction

function! s:CompleteTableStyleOption(ArgLead, CmdLine, CursorPos) abort
    let style = table#config#Style()
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

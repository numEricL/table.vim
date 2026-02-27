let s:save_cpo = &cpo
set cpo&vim

" :Table command - for actions
function! table#commands#TableCommand(...) abort
    if a:0 == 0
        let actions = ['Align', 'Complete', 'DeleteCol', 'DeleteRow', 'EditCell', 'InsertCol', 'InsertRow', 'MoveCol', 'MoveRow', 'SortCols', 'SortRows', 'ToDefault', 'ToStyle']
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
    elseif action ==# 'InsertCol'
        call table#InsertColumn()
    elseif action ==# 'InsertRow'
        call table#InsertRow()
    elseif action ==# 'DeleteCol'
        call table#DeleteColumn()
    elseif action ==# 'DeleteRow'
        call table#DeleteRow()
    elseif action ==# 'MoveCol'
        call s:MoveAction('col', args)
    elseif action ==# 'MoveRow'
        call s:MoveAction('row', args)
    elseif action =~# 'SortCols!\?'
        call s:SortAction('cols', action[-1:] ==# '!', args)
    elseif action =~# 'SortRows!\?'
        call s:SortAction('rows', action[-1:] ==# '!', args)
    elseif action ==# 'ToDefault'
        call table#ToDefault(line('.'))
    elseif action ==# 'ToStyle'
        if len(args) == 0
            echohl ErrorMsg | echomsg 'ToStyle: style name required' | echohl None
            return
        endif
        call table#ToStyle(line('.'), args[0])
    else
        echohl ErrorMsg | echomsg "Table: unknown action '" .. action .. "'" | echohl None
    endif
endfunction

function! table#commands#TableComplete(ArgLead, CmdLine, CursorPos) abort
    let parts = split(a:CmdLine, '\s\+', 1)
    let num_args = len(parts) - 1

    " Complete action names
    if num_args <= 1
        let actions = ['Align', 'Complete', 'DeleteCol', 'DeleteRow', 'EditCell', 'InsertCol', 'InsertRow', 'MoveCol', 'MoveRow', 'SortCols', 'SortRows', 'ToDefault', 'ToStyle']
        return filter(copy(actions), 'v:val =~? "^" .. a:ArgLead')
    endif

    let action = parts[1]

    " Complete style names for ToStyle
    if action ==# 'ToStyle'
        let styles = ['default'] + table#style#GetNames()
        return filter(copy(styles), 'v:val =~? "^" .. a:ArgLead')
    elseif action ==# 'MoveCol'
        return filter(['left', 'right'], 'v:val =~? "^" .. a:ArgLead')
    elseif action ==# 'MoveRow'
        return filter(['up', 'down'], 'v:val =~? "^" .. a:ArgLead')
    endif

    return []
endfunction

" :TableConfig command - for configuration
function! table#commands#TableConfigCommand(...) abort
    if a:0 == 0
        let subcommands = ['Option', 'StyleOption', 'Style', 'RegisterStyle']
        echomsg 'TableConfig subcommands: ' .. join(subcommands, ', ')
        echomsg ' '
        echomsg 'table.vim ' .. table#Version()
        echomsg 'Configuration for buffer ' .. (bufname('%') !=# '' ? bufname('%') : bufnr('%'))
        echomsg 'Current Style = ' .. table#config#Config(bufnr('%')).style
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
        echomsg "TableConfig: unknown subcommand '" .. subcommand .. "'"
        echohl None
    endif
endfunction

function! table#commands#TableConfigComplete(ArgLead, CmdLine, CursorPos) abort
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

function! s:ConvertValue(args) abort
    let key = a:args[0]
    let value = join(a:args[1:], ' ')

    if key ==# 'chunk_size'
        " returns a list with the first two numbers found
        let matches = matchlist(value, '\v(\d+)\D+(\d+)')
        let matches = matches[1:2]
        call map(matches, 'abs(str2nr(v:val))')
        if !empty(matches)
            let matches[0] = -matches[0]
        endif
        return matches
    elseif key ==# 'SortComparator'
        if value[0] ==# '{' && value[-1:] ==# '}'
            return eval(value)
        else
            return funcref(value)
        endif
    endif
    if value ==? 'v:true' || value ==? 'true' || value ==# '1'
        return v:true
    elseif value ==? 'v:false' || value ==? 'false' || value ==# '0'
        return v:false
    elseif value =~# '^\d\+$'
        return str2nr(value)
    else
        return value
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
    " capital in case of funcref (e.g. SortComparator)
    let Value = s:ConvertValue(a:args)
    call table#config#SetBufferConfig(bufnr, { 'options': { key : Value } })
endfunction

function! s:ShowOption(args) abort
    let cfg_opts = table#config#Config(bufnr('%')).options
    echomsg "Table Options:"
    let maxlen = max(map(keys(cfg_opts), 'len(v:val)'))
    let sorted_items = sort(items(cfg_opts), {a, b -> a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0})
    for [key, Value] in sorted_items
        let padded_key = table#util#Pad(key, maxlen)
        echomsg '  ' .. padded_key .. ' = ' .. string(Value)
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
    let value = s:ConvertValue(a:args)
    call table#config#SetBufferConfig(bufnr, { 'style_options': { key : value } })
endfunction

function! s:ShowStyleOption(args) abort
    let style_opts = table#config#Style(bufnr('%')).options
    echomsg "Table StyleOptions:"
    let maxlen = max(map(keys(style_opts), 'len(v:val)'))
    let sorted_items = sort(items(style_opts), {a, b -> a[0] <? b[0] ? -1 : a[0] >? b[0] ? 1 : 0})
    for [key, value] in sorted_items
        let padded_key = table#util#Pad(key, maxlen)
        echomsg '  ' .. padded_key .. ' = ' .. string(value)
    endfor
endfunction

function! s:CompleteOption(ArgLead, CmdLine, CursorPos) abort
    let options = keys(table#config#Config(bufnr('%')).options)
    let parts = split(a:CmdLine, '\s\+')
    let num_args = len(parts) - 1

    if (num_args == 1 && a:CmdLine !~# '\s$') || (num_args == 0 && a:CmdLine =~# '\s$')
        return filter(sort(copy(options), 'i'), 'v:val =~? "^" .. a:ArgLead')
    elseif (num_args == 2 && a:CmdLine !~# '\s$') || (num_args == 1 && a:CmdLine =~# '\s$')
        let option_key = parts[1]
        if option_key ==# 'default_alignment'
            return filter(['left', 'center', 'right'], 'v:val =~? "^" .. a:ArgLead')
        elseif option_key ==# 'multiline'
            return filter(['auto', 'true', 'false'], 'v:val =~? "^" .. a:ArgLead')
        elseif option_key ==# 'multiline_format'
            return filter(['align', 'wrap', 'block_align', 'block_wrap', 'paragraph_wrap'], 'v:val =~? "^" .. a:ArgLead')
        elseif option_key ==# 'auto_split_cell'
            return filter(['true', 'false'], 'v:val =~? "^" .. a:ArgLead')
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

    if (num_args == 1 && a:CmdLine !~# '\s$') || (num_args == 0 && a:CmdLine =~# '\s$')
        let keys_list = keys(style.options)
        return filter(copy(keys_list), 'v:val =~? "^" .. a:ArgLead')
    elseif (num_args == 2 && a:CmdLine !~# '\s$') || (num_args == 1 && a:CmdLine =~# '\s$')
        let key = parts[1]
        if key =~# '^omit_'
            return filter(['true', 'false'], 'v:val =~? "^" .. a:ArgLead')
        endif
    endif
    return []
endfunction

function! s:MoveAction(type, args) abort
    let action_name = (a:type ==# 'col')? 'MoveColumn' : 'MoveRow'
    if len(a:args) == 0
        let allowed_directions = (a:type ==# 'col')? '<left|right>' : '<up|down>'
        echomsg 'Usage: :Table '.. action_name .. ' ' .. allowed_directions
        return
    endif
    let direction = a:args[0]
    if a:type ==# 'col' && (direction ==# 'left' || direction ==# 'right')
        call table#MoveColumn(direction)
    elseif a:type ==# 'row' && (direction ==# 'up' || direction ==# 'down')
        call table#MoveRow(direction)
    else
        echomsg 'Invalid direction "' .. direction .. '" for ' .. action_name
    endif
endfunction

function! s:SortAction(type, bang, args) abort
    let sort_args = s:ParseSortArgs(a:type, a:bang, a:args)
    if sort_args.error
        return
    endif
    call table#Sort(line('.'), a:type, sort_args.id, sort_args.flags)
endfunction

function! s:ParseSortArgs(type, bang, args) abort
    let allowed_flags = ['i', 'n', 'f', 'c']
    let func_name = (a:type ==# 'rows')? 'SortRows' : 'SortCols'
    let id_name   = (a:type ==# 'rows')? 'col' : 'row'

    if len(a:args) == 0
        " print calling convention if no args provided
        echomsg 'Usage: :Table ' .. func_name .. '[!] <' .. id_name .. '_id> ' .. '[' .. join(allowed_flags, '|') .. ']'
        return { 'error': v:true }
    endif

    let sort_args = { 'id': v:false, 'flags': [], 'error': v:false }
    for arg_id in range(len(a:args))
        if a:args[arg_id] =~# '^\d\+$'
            if type(sort_args.id) != v:t_bool
                echohl ErrorMsg | echomsg func_name .. ': only one ' .. id_name .. '_id allowed' | echohl None
                let sort_args.error = v:true
            endif
            let sort_args.id = str2nr(a:args[arg_id]) - 1
        else
            call extend(sort_args.flags, split(a:args[arg_id], '\zs'))
        endif
    endfor
    if a:bang
        call extend(sort_args.flags, ['!'])
    endif

    if type(sort_args.id) == v:t_bool
        echohl ErrorMsg | echomsg func_name .. ': ' .. id_name .. '_id required' | echohl None
        let sort_args.error = v:true
        return sort_args
    endif

    for flag in sort_args.flags
        if index(allowed_flags, flag) == -1 && flag !=# '!'
            echohl ErrorMsg | echomsg func_name .. ': invalid flag "' .. flag .. '"' | echohl None
            let sort_args.error = v:true
        endif
    endfor
    return sort_args
endfunction

function! table#commands#TableOptionCommand(...) abort
    echomsg 'TableOption command is deprecated, use TableConfig instead'
    echomsg ''
    call call('table#commands#TableConfigCommand', a:000)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

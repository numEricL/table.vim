function! table#lua_bridge#Draw_CurrentlyPlaced() abort
    if exists('g:table_vim_lua_bridge')
        call table#draw#CurrentlyPlaced(g:table_vim_lua_bridge)
    endif
endfunction

function! table#lua_bridge#Table_RestoreMethods() abort
    if exists('g:table_vim_lua_bridge')
        call table#table#RestoreMethods(g:table_vim_lua_bridge)
    endif
endfunction

function! table#lua_bridge#Cursor_GetCoord(pos, ...) abort
    if exists('g:table_vim_lua_bridge')
        if a:0
            return table#cursor#GetCoord(g:table_vim_lua_bridge, a:pos, a:1)
        else
            return table#cursor#GetCoord(g:table_vim_lua_bridge, a:pos)
        endif
    endif
    return {}
endfunction

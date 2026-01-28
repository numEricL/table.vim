---@diagnostic disable: lowercase-global

local M = {}

-- vimscript to/from lua table conversions don't carry over methods
-- for lua usage we pass the tbl explicitly, for vimscript usage we wrap in a
-- closure
function M.set_lua_methods(tbl)
    local methods = require('table.methods')
    tbl.Cell = methods.table_get_cell
    tbl.SetCell = methods.table_set_cell
end

function M.set_vim_methods(tbl)
    local methods = require('table.methods')
    -- Store table reference in a VimScript variable so methods can access the live version
    vim.g._table_vim_bridge_ref = tbl
    
    tbl.ColAlign = function(col) 
        local t = vim.g._table_vim_bridge_ref
        return methods.table_col_align(t, col) 
    end
    tbl.ColCount = function() 
        local t = vim.g._table_vim_bridge_ref
        return methods.table_col_count(t) 
    end
    
    for i, row in ipairs(tbl.rows) do
        row.Height = function() 
            local t = vim.g._table_vim_bridge_ref
            return methods.cell_row_height(t.rows[i]) 
        end
        row.ColCount = function() 
            local t = vim.g._table_vim_bridge_ref
            return methods.cell_col_count(t.rows[i]) 
        end
    end
end

function M.get(linenr, chunk_size)
    local tbl = vim.fn['table#table#Get'](linenr, chunk_size)
    M.set_lua_methods(tbl)
    return tbl
end

return M

 -- I am adding a lua feature to a vimscript plugin. I need a bridge between lua and vimscript. The central object is a tbl, in vimscript it is a dictionary
 --   with data members and funcrefs that are used as methods. I have reimplemented them in lua. this works going from vimscript to lua, but not the other way
 --   around. The vimscript calls mutate the tbl, but these methods mutate a copy of the lua table, not the dicts that the vimscript sees. how do i fix it?
 --   Ideally just set_vim_methods would change

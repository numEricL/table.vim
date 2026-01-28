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
    tbl.ColAlign = function(col) return methods.table_col_align(col) end
    tbl.ColCount = function() return methods.table_col_count() end
    for _, row in ipairs(tbl.rows) do
        row.Height = function() return methods.cell_row_height() end
        row.ColCount = function() return methods.cell_col_count() end
    end
end

function M.get(linenr, chunk_size)
    local tbl = vim.fn['table#table#Get'](linenr, chunk_size)
    M.set_lua_methods(tbl)
    return tbl
end

return M

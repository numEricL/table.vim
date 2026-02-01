local methods = require('vim_bridge_methods')

local M = {}

local function set_lua_methods(tbl)
    if not tbl.valid then
        return
    end
    tbl.Cell = methods.table_get_cell
    tbl.SetCell = methods.table_set_cell
    for _, row in ipairs(tbl.rows) do
        row.RowHeight = methods.cell_row_height
        row.ColCount = methods.cell_col_count
    end
end

local function set_vim_methods(tbl)
    vim.g.table_vim_lua_bridge = tbl
    vim.fn['table#lua_bridge#Table_RestoreMethods']()
end

-- vimscript wrappers
function M.config__config()
    return vim.fn['table#config#Config']()
end

function M.cursor__get_coord(tbl, pos, type_override)
    set_vim_methods(tbl)
    return vim.fn['table#lua_bridge#Cursor_GetCoord'](pos, type_override)
end

function M.draw__currently_placed(tbl)
    set_vim_methods(tbl)
    vim.fn['table#lua_bridge#Draw_CurrentlyPlaced']()
end

function M.table__get(linenr, chunk_size)
    local tbl = vim.fn['table#table#Get'](linenr, chunk_size)
    set_lua_methods(tbl)
    return tbl
end

function M.textobj__cell(count1, type)
    return vim.fn['table#textobj#Cell'](count1, type)
end

return M

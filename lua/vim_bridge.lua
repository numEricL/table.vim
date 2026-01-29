local methods = require('vim_bridge_methods')

local M = {}

local function set_lua_methods(tbl)
    tbl.Cell = methods.table_get_cell
    tbl.SetCell = methods.table_set_cell
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
    return vim.fn['table#cursor#GetCoord'](tbl, pos, type_override)
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

return M

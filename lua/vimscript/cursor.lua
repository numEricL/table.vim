local M = {}

function M.get_coord(tbl, pos, type_override)
    return vim.fn['table#cursor#GetCoord'](tbl, pos, type_override)
end

return M

local M = {}

function M.currently_placed(tbl)
    vim.fn['table#draw#CurrentlyPlaced'](tbl)
end

return M

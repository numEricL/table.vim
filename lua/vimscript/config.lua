local M = {}

-- if vim.fn.exists('*table#config#Config') == 0 then
--     vim.cmd('runtime table/config.vim')
-- end

function M.config()
    return vim.fn['table#config#Config']()
end

return M

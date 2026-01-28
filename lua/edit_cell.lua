local bridge = require('vim_bridge')

local M = {}

local CellBufNr = nil

local function find_window(bufnr)
    local wins = vim.api.nvim_list_wins()
    for _, win in ipairs(wins) do
        if vim.api.nvim_win_get_buf(win) == bufnr then
            return win
        end
    end
    return nil
end

local function open_window()
    if not CellBufNr then
        CellBufNr = vim.api.nvim_create_buf(false, true)
    end
    local bufnr = CellBufNr
    local winid = find_window(bufnr)
    if not winid then
        local opts = {
            relative = 'cursor',
            row = 5,
            col = 0,
            width = 20,
            height = 5,
        }
        winid = vim.api.nvim_open_win(bufnr, false, opts)
        vim.wo[winid].number = false
    end
    vim.api.nvim_set_current_win(winid)
    return winid, bufnr
end

local function update_cell(tbl, cell_id, bufnr)
    ---@diagnostic disable-next-line: deprecated
    local row_id, _, col_id = unpack(cell_id)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    tbl:SetCell(row_id, col_id, lines)
end

local function update_table_on_window_close(tbl, cell_id, winid)
    local group = vim.api.nvim_create_augroup("table.vim", {})
    vim.api.nvim_create_autocmd("WinClosed", {
        callback = function(args)
            if tonumber(args.match) == winid then
                local scracth_bufnr = vim.api.nvim_win_get_buf(winid)
                update_cell(tbl, cell_id, scracth_bufnr)
                bridge.draw__currently_placed(tbl)
            end
        end,
        once = true,
        group = group,
    })
end

function M.edit_cell(tbl, cell_id)
    local winid, bufnr = open_window()
    ---@diagnostic disable-next-line: deprecated
    local row_id, _, col_id = unpack(cell_id)
    local cell = tbl:Cell(row_id, col_id)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, cell)
    update_table_on_window_close(tbl, cell_id, winid)
end

function Foo()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cfg_opts = bridge.config__config().options
    local tbl = bridge.table__get(cursor[1], cfg_opts.chunk_size)
    local cell_id = bridge.cursor__get_coord(tbl, cursor, 'cell').coord
    M.edit_cell(tbl, cell_id)
end

return M

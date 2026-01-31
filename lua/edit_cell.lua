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

local function get_buf_size(buf)
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local max_width = 0
    for _, line in ipairs(lines) do
        local width = vim.fn.strdisplaywidth(line)
        max_width = math.max(max_width, width)
    end
    return #lines, max_width
end

local function resize_win_to_fit_buf(winid)
    local bufnr = vim.api.nvim_win_get_buf(winid)
    local height, width = get_buf_size(bufnr)
    vim.api.nvim_win_set_config(winid, {
        width = width,
        height = height,
    })
    vim.fn.winrestview({
        topline = 1,
        leftcol = 0,
    })

end

local function open_resizable_window(cfg)
    if not CellBufNr then
        CellBufNr = vim.api.nvim_create_buf(false, true)
    end
    local bufnr = CellBufNr
    local winid = find_window(bufnr)
    if not winid then
        winid = vim.api.nvim_open_win(bufnr, true, cfg)
        vim.wo[winid].number = false
        vim.wo[winid].scrolloff = 0
        vim.wo[winid].sidescrolloff = 0
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

local function set_window_autocmds(tbl, cell_id, winid)
    local group = vim.api.nvim_create_augroup("table.vim", {})

    -- resize window on text change
    vim.api.nvim_create_autocmd({"TextChanged", "TextChangedI"}, {
        group = group,
        buffer = vim.api.nvim_win_get_buf(winid),
        callback = function()
            resize_win_to_fit_buf(winid)
        end,
    })

    -- update cell on winleave, and then delete the augroup
    vim.api.nvim_create_autocmd("WinLeave", {
        once = true,
        group = group,
        callback = function()
            if vim.api.nvim_get_current_win() == winid then
                local bufnr = vim.api.nvim_win_get_buf(winid)
                update_cell(tbl, cell_id, bufnr)
                bridge.draw__currently_placed(tbl)
                vim.api.nvim_win_close(winid, false)
                vim.api.nvim_del_augroup_by_id(group)
            end
        end,
    })
end

local function edit_cell(tbl, cell_id)
    local textobj = bridge.textobj__cell(1, 'inner')

    local current_winid = vim.api.nvim_get_current_win()
    local screenpos = vim.fn.screenpos(current_winid, textobj['start'][1], textobj['start'][2])
    local win_cfg = {
       relative = 'editor',
       row = screenpos.row - 2,
       col = screenpos.col - 2,
       height = textobj['end'][1] - textobj['start'][1] + 1,
       width  = textobj['end'][2] - textobj['start'][2] + 1,
    }
    local winid, bufnr = open_resizable_window(win_cfg)
    ---@diagnostic disable-next-line: deprecated
    local row_id, _, col_id = unpack(cell_id)
    local cell = tbl:Cell(row_id, col_id)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, cell)
    set_window_autocmds(tbl, cell_id, winid)
end

function M.edit_cell_under_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cfg_opts = bridge.config__config().options
    local tbl = bridge.table__get(cursor[1], cfg_opts.chunk_size)
    local cell_id = bridge.cursor__get_coord(tbl, cursor, 'cell').coord
    edit_cell(tbl, cell_id)
end

return M

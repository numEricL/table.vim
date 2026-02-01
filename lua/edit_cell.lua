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

    local extra_col = 0
    if vim.fn.mode():match('^[i]') then
        local cursor = vim.api.nvim_win_get_cursor(winid)
        if cursor[2] >= width then
            extra_col = 1
        end
    end

    vim.api.nvim_win_set_config(winid, {
        width = math.max(width + extra_col, 1),
        height = math.max(height, 1),
    })
    vim.fn.winrestview({
        topline = 1,
        leftcol = 0,
    })

end

local function cached_buf()
    if not CellBufNr then
        CellBufNr = vim.api.nvim_create_buf(false, true)
    end
    return CellBufNr
end

local function init_buffer(lines)
    local bufnr = cached_buf()
    local old_undolevels = vim.bo[bufnr].undolevels
    vim.bo[bufnr].undolevels = -1
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.bo[bufnr].undolevels = old_undolevels
    return bufnr
end

local function init_window(bufnr, textobj)
    local current_winid = vim.api.nvim_get_current_win()
    local screenpos = vim.fn.screenpos(current_winid, textobj['start'][1], textobj['start'][2])
    local cfg = {
        relative = 'editor',
        row = screenpos.row - 2,
        col = screenpos.col - 2,
        height = textobj['end'][1] - textobj['start'][1] + 1,
        width  = textobj['end'][2] - textobj['start'][2] + 1,
    }
    local winid = find_window(bufnr)
    if not winid then
        winid = vim.api.nvim_open_win(bufnr, false, cfg)
        vim.wo[winid].number = false
        vim.wo[winid].scrolloff = 0
        vim.wo[winid].sidescrolloff = 0
        vim.wo[winid].winfixbuf = true
    end
    return winid
end

local function update_cell(tbl, cell_id, bufnr)
    ---@diagnostic disable-next-line: deprecated
    local row_id, _, col_id = unpack(cell_id)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    tbl:SetCell(row_id, col_id, lines)
end

local function set_window_autocmds(tbl, cell_id, winid, bufnr)
    local group = vim.api.nvim_create_augroup("table.vim", {})

    -- resize window on text change
    vim.api.nvim_create_autocmd({"CursorMovedI", "InsertLeave"}, {
        group = group,
        buffer = bufnr,
        callback = function()
            resize_win_to_fit_buf(winid)
        end,
    })

    -- close window on winleave
    vim.api.nvim_create_autocmd("WinLeave", {
        group = group,
        nested = true,
        callback = function()
            if vim.api.nvim_get_current_win() == winid then
                vim.api.nvim_win_close(winid, false)
            end
        end,
    })

    -- update cell and delete augroup on window close
    vim.api.nvim_create_autocmd("WinClosed", {
        group = group,
        callback = function()
            local closed_winid = tonumber(vim.fn.expand("<amatch>"))
            if closed_winid == winid then
                -- Fire user event for cell edit window close
                vim.api.nvim_exec_autocmds('User', {
                    pattern = 'TableCellEditPost',
                    data = { bufnr = bufnr, winid = winid, table = tbl, cell_id = cell_id }
                })

                update_cell(tbl, cell_id, bufnr)
                bridge.draw__currently_placed(tbl)
                vim.api.nvim_del_augroup_by_id(group)
            end
        end,
    })
end

local function edit_cell(tbl, cell_id)
    local cell = tbl:Cell(cell_id[1], cell_id[3])
    local bufnr = init_buffer(cell)

    local textobj = bridge.textobj__cell(1, 'inner')
    local winid = init_window(bufnr, textobj)
    set_window_autocmds(tbl, cell_id, winid, bufnr)

    local pos = vim.api.nvim_win_get_cursor(0)
    pos = {pos[1] - textobj['start'][1] + 1, pos[2] - textobj['start'][2] + 1}
    vim.api.nvim_set_current_win(winid)
    vim.api.nvim_win_set_cursor(winid, pos)

    -- Fire user event for cell edit window open
    vim.api.nvim_exec_autocmds('User', {
        pattern = 'TableCellEditPre',
        data = { bufnr = bufnr, winid = winid, table = tbl, cell_id = cell_id }
    })
end

function M.edit_cell_under_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local cfg_opts = bridge.config__config().options
    local tbl = bridge.table__get(cursor[1], cfg_opts.chunk_size)
    local cell_id = bridge.cursor__get_coord(tbl, cursor, 'cell').coord
    edit_cell(tbl, cell_id)
end

return M

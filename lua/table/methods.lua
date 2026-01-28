local M = {}

function M.table_get_cell(tbl, row, col)
    local lua_array_offset = 1
    row = row + lua_array_offset
    col = col + lua_array_offset
    local row_obj = tbl.rows[row]
    if col > #(row_obj.cells) then
        return {}
    end
    return row_obj.cells[col]
end

function M.table_set_cell(tbl, row, col, lines)
    if #lines > 1 then
        vim.cmd('Table Option multiline 1')
    end
    local lua_array_offset = 1
    row = row + lua_array_offset
    col = col + lua_array_offset
    local row_obj = tbl.rows[row]
    row_obj.cells[col] = lines
end

-- function M.table_col_count(tbl)
--     return tbl.max_col_count
-- end
-- 
-- function M.table_col_align(tbl, col)
--     local cfg_opts = require('vim_bridge').config__config().options
--     local default_align = cfg_opts.default_alignment
--     local lua_array_offset = 1
--     col = col + lua_array_offset
--     local align = tbl.col_align[col] or default_align
--     align = (align == '') and default_align or align
--     return align
-- end
-- 
-- function M.cell_row_height(row)
--     local height = 0
--     for _, cell in ipairs(row.cells) do
--         height = math.max(height, #cell)
--     end
--     return height
-- end
-- 
-- function M.cell_col_count(row)
--     return #row.cells
-- end

return M

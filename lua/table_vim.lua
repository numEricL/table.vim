local M = {}

-- @param opts table: Configuration options
--   - disable_mappings: boolean - Disable default mappings (default: false)
--   - disable_ftplugins: boolean - Disable built-in ftplugin configuration files (default: false)
--   - style: string - Table style name (e.g., 'markdown', 'org', 'single', 'double')
--   - options: table - Table options
--     - multiline: string - Allow cells to contain newlines
--     - multiline_format: string - formatting to be applied to multiline cells: 'align' 'wrap' 'block_align' 'block_wrap' 'paragraph_wrap'
--     - default_alignment: string - Default column alignment: 'left', 'center', or 'right'
--     - chunk_size: list - Chunk size for parsing
--     - i_vertical: string - Input vertical character
--     - i_horizontal: string - Input horizontal character
--     - i_alignment: string - Input alignment character
--   - style_options: table - Style-specific options
--     - omit_left_border: boolean
--     - omit_right_border: boolean
--     - omit_top_border: boolean
--     - omit_bottom_border: boolean
--     - omit_separator_rows: boolean
function M.setup(opts)
    opts = opts or {}
    vim.fn['table#config#Setup'](opts)
end

M.version = vim.fn['table#Version']()

return M

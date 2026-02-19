# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
- **Fixed-width columns**: Support for org-style alignment tags (`<l30>`, `<c10>`, `<r20>`)
  - Tags specify alignment (left/center/right) and column width
  - Automatic text wrapping for cells exceeding column width
- **Automatic multiline row detection**:
  - detects if a table has multiline rows by checking for separator patterns
  - Enabled when `multiline` option is set to `'auto'` (now the default)
- **Multiline formatting options**:
  - New `multiline_format` option with values: `'align'`, `'wrap'`, `'block_align'`, `'block_wrap'` (default), `'paragraph_wrap'`
- Cell editor now automatically fills missing multiline rows when editing cells

### Fixed
- Sort functionality now works correctly with right-aligned columns
- Org-style alignment detection no longer triggers false positives on empty lines
- Improved table parser to handle column bounds for visual block operations
- Fixed cleanup in table drawing lines to clear removed data
- Fixed alignment row identification when placement align_sep_id is unset

### Changed
- **BREAKING**: Changed `multiline` option default from `v:false` to `'auto'`
  - Now auto-detects multiline rows based on separator patterns in the table
  - Set to `v:true` or `v:false` for explicit control
- **BREAKING**: Replaced `preserve_indentation` with `multiline_format` option
- `:TableOption` command renamed to `:TableConfig`.
- org-style alignment tags take precedence over alignment header

### Deprecated
- `:TableOption` command is deprecated in favor of `:TableConfig`
  - `:TableOption` still works but shows a deprecation warning

## [v0.1.1] - 2026-02-15

### Fixed
- Fixed cursor positioning when inserting pipe character on top of an existing pipe
- Fixed cursor positioning on separator row after pipe insertion
- Tab cycle works on non-aligned tables now
- Clarified that `cell_id.row_id` is relative to chunked table, not absolute buffer coordinates

### Changed
- Use an empty `chunk_size` to indicate handling the entire table instead of a special value

### Added
- `g:table_cell_edit_data` global variable for accessing cell editor event data in Vimscript

## [v0.1.0] - 2026-02-13

### Added
- **Table sorting functionality**: Sort table rows by column or columns by row
  - `:Table SortRows[!] {col} [flags]` - Sort rows by specified column (! for reverse)
  - `:Table SortCols[!] {row} [flags]` - Sort columns by specified row (! for reverse)
  - Support for alphabetical (default), numeric (n), and custom (c) sort flags
  - User-defined sort comparator functions for custom sorting logic
- Versioning system following semantic versioning (vMAJOR.MINOR.PATCH)
- CHANGELOG.md to track changes between versions

### Features
- Multiline rows support
- Cell editing window (floating window in Neovim, split in Vim)
- Text objects for cells, rows, and columns
- Multiple table styles (markdown, org, rst, box-drawing)
- Chunk processing for performance with large tables
- Auto-alignment on pipe insertion
- Context-aware keybindings
- Tab navigation between cells

### Requirements
- Vim 8.1 or later
- Neovim 0.11.5 or later

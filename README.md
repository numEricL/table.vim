# table.vim v0.3.0

Advanced table editing for Vim and Neovim. Easily create, edit, and format
tables with support for multi-line rows, fixed-width columns, sorting, and
various table styles. Edit cell content in a separate window for enhanced
control. Highly configurable and extensible.

## Quick Start

Create tables using pipes `|` and dashes `-`. The table is aligned and redrawn
automatically on pipe insertion. Table style is configurable, "double" is shown
here:

```
|Header 1| Header 2|Header 3|           ║ Header 1 ║ Header 2 ║ Header 3 ║
|--                              -->    ╠══════════╣
|Cell 1          |Cell 2 ░              ║ Cell 1   ║ Cell 2   ║░
```

And may be completed to:

```
╔══════════╦══════════╦══════════╗
║ Header 1 ║ Header 2 ║ Header 3 ║
╠══════════╬══════════╬══════════╣
║ Cell 1   ║ Cell 2   ║          ║
╚══════════╩══════════╩══════════╝
```

- Use `:Table <action>` to perform table actions like completion, sorting, and style conversion.
- Use `:TableConfig <option>` to view and change configuration at runtime, such as enabling multiline rows or changing the table style.

See [`:help table.txt`](doc/table.txt) for complete documentation.

## Requirements

- Vim 8.1 or later
- Neovim 0.11.5 or later

## Upgrading from v0.1.x

- **Multiline rows** are now auto-detected by default. Set `multiline` to `true` or `false` to override.
- **`:TableOption`** is deprecated. Use **`:TableConfig`** instead.
- If you used `preserve_indentation`, switch to `multiline_format` (see `:help table-configuration`). Default behavior is unchanged.

## Features

- **Multiline rows**             - auto-detected by default
- **Auto-split multiline cells** - inserting a pipe splits the entire cell (enable via `auto_split_cell` option)
- **Fixed-width columns**        - hard-wrap columns with alignment tags
- **Cell editing window**        - edit in a floating window, hooks provided (split window in Vim)
- **Sorting**                    - sort rows and columns by any column/row
- **Table navigation**           - move between cells even if the table is not yet aligned
- **Text objects**               - cell, row, and column
- **Multiple table styles**      - markdown, org, rst, and box-drawing styles included, or define your own

## Demo

Note: This demo is from an older version, options have changed.

https://github.com/user-attachments/assets/352e23b0-33ba-4f9d-9fa0-e2aee5fd16cc

## Configuration (optional)

Configuration is **buffer-local**. Set defaults in your vimrc, customize
per-filetype in after/ftplugin files, or change at runtime with `:TableConfig`.

```vim
" .vimrc - set defaults for all buffers (overridden by ftplugins)
call table#Setup({
    \ 'style': 'default',
    \ 'options': {'multiline': 'auto', 'multiline_format': 'block_wrap'}
    \ })
```

```lua
-- init.lua - set defaults for all buffers (overridden by ftplugins)
require('table_vim').setup({
    style = 'default',
    options = { multiline = 'auto', multiline_format = 'block_wrap' }
})
```

See `:help table-configuration` for details.

## Cell Editing

`:Table EditCell` opens cells in a split (Vim) or floating (Neovim) window for
greater control over editing. Especially useful for multiline cells.

The window closes automatically when you leave it (`:q` or `<C-w>c`), and
changes are saved back to the table.

Use `TableCellEditPre` and `TableCellEditPost` autocommands to customize
behavior.

See `:help table-events`.

## Keybindings

Auto-alignment, navigational, and text object keybindings are mapped by default.
All default keybindings are **context-aware**, they only activate when the
cursor is on a line containing a table. Outside of tables, your existing
keybindings work normally.

### Navigation

- `<Tab>` / `<S-Tab>` - Next/previous cell
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Navigate left/down/up/right

### Text Objects

Cell, row, and column text objects are provided for visual and operator-pending
modes. Default selects half borders; use "around" for full borders or "inner"
for no borders. Half borders are useful for reordering table components.

| Object     | Description    | Example                   |
|------------|----------------|---------------------------|
| `tx/ix/ax` | cell           | `cix` change cell content |
| `tr/ir/ar` | row            | `dtr` delete row          |
| `tc/ic/ac` | column         | `yac` yank full column    |

### Available `<Plug>` Mappings

Table actions have no default keybindings, but may be mapped with the provided
`<Plug>` mappings.

```vim
" Example custom mappings (add to vimrc/init.vim)
nnoremap <leader>ta    <Plug>(table_align)
nnoremap <leader><bar> <Plug>(table_complete)
nnoremap <leader>td    <Plug>(table_to_default)
nnoremap <leader>te    <Plug>(table_cell_edit)
nnoremap <leader>tir   <Plug>(table_insert_row)
nnoremap <leader>tic   <Plug>(table_insert_column)
nnoremap <leader>tdr   <Plug>(table_delete_row)
nnoremap <leader>tdc   <Plug>(table_delete_column)
nnoremap <leader>tmk   <Plug>(table_move_row_up)
nnoremap <leader>tmj   <Plug>(table_move_row_down)
nnoremap <leader>tmh   <Plug>(table_move_column_left)
nnoremap <leader>tml   <Plug>(table_move_column_right)
```

## Commands

Two top level commands are defined, `:Table` and `:TableConfig`. Tab-completion
is available for all subcommands and arguments.

### `:Table` - Table Actions

```vim
:Table EditCell                  " Edit cell in split (Vim) or floating (Neovim) window
:Table Complete                  " Fill missing cells and borders (processes entire table)
:Table Align                     " Align table columns (processes chunk near cursor)
:Table InsertRow                 " Insert a new row at cursor position
:Table InsertCol                 " Insert a new column at cursor position
:Table DeleteRow                 " Delete the row at cursor position
:Table DeleteCol                 " Delete the column at cursor position
:Table MoveRow {up|down}         " Move current row up or down
:Table MoveCol {left|right}      " Move current column left or right
:Table SortRows[!] {col} [flags] " Sort rows by specified column (! for reverse)
:Table SortCols[!] {row} [flags] " Sort columns by specified row (! for reverse)
:Table ToDefault                 " Convert to default style (using i_vertical/i_horizontal)
:Table ToStyle {style}           " Convert to specified style and update buffer style
```

### `:TableConfig` - Runtime Configuration

Runtime configuration for the current buffer. Use without arguments to show
current configuration.

```vim
:TableConfig                              " Show all current settings
:TableConfig Style [name]                 " Get/set style
:TableConfig Option [key] [value]         " Get/set option
:TableConfig StyleOption [key] [value]    " Get/set style option
:TableConfig RegisterStyle [name]         " Register current style (session only)
```

**Note:** `:TableOption` is deprecated, use `:TableConfig` instead.

**Note:** Style registration is only for the current session. Add the
registration to your vimrc/init.lua for persistence.

## Sorting

Sort table rows by a specific column or sort columns by a specific row:

```vim
:Table SortRows 2      " Sort rows by column 2 (alphabetical)
:Table SortCols! 3 n   " Reverse sort columns by row 3 (numeric)
:Table SortRows 1 c    " Custom sort via user defined comparator function
```

See `:help :Table-SortRows` and `:help :Table-SortCols`

## Fixed-Width Columns

Set column widths using alignment tags. Tags use the format
`<[alignment][width]>` where alignment is `l` (left), `c` (center), or `r`
(right), and width is a positive integer. Columns are padded to the specified
width, and, if `multiline` is enabled and a `multiline_format` wrap option is
set, long columns are also hard-wrapped to the specified width.

```vim
| Description        |   Column 1 width    |
|--------------------|---------------------|
| <l30>              |        <c10>        |
| Next col will wrap | This cell will wrap |


| Description        | Column 1  |
|                    |   width   |
|--------------------|-----------|
| <l30>              |   <c10>   |
| Next col will wrap | This cell |
|                    | will wrap |
```

Enable wrapping in configuration:
```vim
call table#Setup({
    \ 'options': {'multiline': 'auto', 'multiline_format': 'block_wrap'}
    \ })
```

See `:help table-fixed-width` for details.

## Chunk Processing

For performance, the align action (auto-align and `:Table Align`) only processes
the lines near the cursor according to the `chunk_size` option. The `:Table
Complete` command processes the entire table and may be slow for large tables.

## Table Detection

Tables must be
- At least two lines (rows)
- Separated by blank lines above and below (comment strings are ok)

## Limitations

- No merged/spanning cells (multiline rows are supported)
- `i_vertical` and `i_horizontal` must be different characters

## License

Mozilla Public License 2.0 - See [LICENSE](LICENSE)

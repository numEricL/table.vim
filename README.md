# table.vim

Text table manipulation for Vim and Neovim.

## Quick Start

Create tables using pipes `|` and dashes `-`. The table is aligned and redrawn
automatically on pipe insertion. Table style is configurable.

```
|Header 1| Header 2|Header 3|           ║ Header 1 ║ Header 2 ║ Header 3 ║
|--                              -->    ╠══════════╣
|Cell 1          |Cell 2 ░              ║ Cell 1   ║ Cell 2   ║
```

And may to completed to:

```
╔══════════╦══════════╦══════════╗
║ Header 1 ║ Header 2 ║ Header 3 ║
╠══════════╬══════════╬══════════╣
║ Cell 1   ║ Cell 2   ║          ║
╚══════════╩══════════╩══════════╝
```

- Use `:Table Align` to manually align tables
- Use `:Table Complete` to fill missing cells and borders
- Use `<Tab>` / `<S-Tab>` to navigate between cells
- Use `:TableOption` to configure table or style options

See [`:help table.txt`](doc/table.txt) for complete documentation.

## Requirements

- Vim 8.1 or later
- Neovim 0.11.5 or later

## Features

- **Multiline rows**        - must be enabled in your configuration
- **Cell editing window**   - edit in a floating window, hooks provided (split window in Vim)
- **Sorting**               - sort rows and columns
- **Text objects**          - cell, row, and column
- **Multiple table styles** - markdown, org, rst, and box-drawing styles included, or define your own
- **Chunk processing**      - align only nearby lines for fast operation with large tables

## Demo

https://github.com/user-attachments/assets/352e23b0-33ba-4f9d-9fa0-e2aee5fd16cc

## Configuration (optional)

Configuration is **buffer-local**. Set defaults in your vimrc, customize
per-filetype in after/ftplugin files, or change at runtime with `:TableOption`.

```vim
" .vimrc - set defaults for all buffers (overridden by ftplugins)
call table#Setup({
    \ 'style': 'default',
    \ 'options': {'multiline': v:true}
    \ })
```

```lua
-- init.lua - set defaults for all buffers (overridden by ftplugins)
require('table_vim').setup({
    style = 'default',
    options = { multiline = true }
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

- `<Tab>` / `<S-Tab>` - Next/previous cell (wraps rows)
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
```

## Commands

Two top level commands are defined, `:Table` and `:TableOption`. Tab-completion
is available for all subcommands and arguments.

### `:Table` - Table Actions

```vim
:Table EditCell                  " Edit cell in split (Vim) or floating (Neovim) window
:Table Complete                  " Fill missing cells and borders (processes entire table)
:Table Align                     " Align table columns (processes chunk near cursor)
:Table SortRows[!] {col} [flags] " Sort rows by specified column (! for reverse)
:Table SortCols[!] {row} [flags] " Sort columns by specified row (! for reverse)
:Table ToDefault                 " Convert to default style (using i_vertical/i_horizontal)
:Table ToStyle {style}           " Convert to specified style and update buffer style
```

### `:TableOption` - Runtime Configuration

Runtime configuration for the current buffer. Use without arguments to show
current configuration.

```vim
:TableOption                              " Show all current settings
:TableOption Style [name]                 " Get/set style
:TableOption Option [key] [value]         " Get/set option
:TableOption StyleOption [key] [value]    " Get/set style option
:TableOption RegisterStyle [name]         " Register current style (session only)
```

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

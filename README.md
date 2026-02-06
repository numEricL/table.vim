# table.vim

Text table manipulation for Vim and Neovim.

## Quick Start

Create tables using pipes (`|`) and dashes (`-`). The table is aligned and
redrawn with style characters automatically on pipe insertion.

Use the `:Table Align` command to perform alignment manually.
Use the `:Table Complete` command fill missing cells and borders.

## Features

- **Multiline rows** - Support for cells containing newlines (must be enabled)
- **Cell editing window** - Edit in a floating window, hooks provided (split window in Vim)
- **Chunk processing** - Align only nearby lines for fast operation with large tables
- **Multiple table styles** - Use a built-in style or define your own

## Demo

https://github.com/user-attachments/assets/352e23b0-33ba-4f9d-9fa0-e2aee5fd16cc

## Table Detection

Tables must be
- At least two lines (rows)
- Separated by blank lines above and below (comment strings are ok)

## Configuration (optional)

Configuration is **buffer-local**. Set defaults in your vimrc, customize
per-filetype in ftplugin files, or change at runtime with `:TableOption`.

```vim
" vimrc - set defaults for all buffers (overidden by ftplugins)
call table#Setup({
    \ 'style': 'default',
    \ 'options': {'multiline': v:true}
    \ })
```

```lua
-- init.lua - set defaults for all buffers (overidden by ftplugins)
require('table_vim').setup({
    style = 'default',
    options = { multiline = true }
})
```

The plugin provides default configurations for markdown, org, and rst filetypes.
To override these, create your own ftplugin files in `after/ftplugin/`.

**Disable features:**
```vim
call table#Setup({
    \ 'disable_mappings': v:true,
    \ 'disable_ftplugins': v:true
    \ })
```

See `:help table-configuration` for details.

## Navigation

- `<Tab>` / `<S-Tab>` - Next/previous cell (wraps rows)
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Navigate left/down/up/right
- Counts work: `3<Tab>` moves three cells forward

## Text Objects

Cell, row, and column text objects are provided for visual and operator-pending
modes. Default selects half borders; use "around" for full borders or "inner"
for no borders.

| Object     | Description    | Example                   |
|------------|----------------|---------------------------|
| `tx/ix/ax` | cell           | `cix` change cell content |
| `tr/ir/ar` | row            | `dtr` delete row          |
| `tc/ic/ac` | column         | `yac` yank full column    |

Counts work: `d2tc` deletes two columns.

See `:help table-text-objects` for details.

## Chunk Processing

For performance, the align action (auto-align and `:Table Align`) only processes
the lines near the cursor. The `:Table Complete` command processes the entire
table and may be slow for large tables.

## Cell Editing

`:Table EditCell` opens cells in a split window (Vim) or floating window (Neovim)
for greater control over editing. Especially useful for multiline cells. Use
`TableCellEditPre` and `TableCellEditPost` autocommands to customize behavior.
See `:help table-events`.

## Commands

### :Table

```vim
:Table EditCell         " Edit cell in split/floating window
:Table Complete         " Fill missing cells and borders
:Table Align            " Align table columns
:Table ToDefault        " Convert to default style
:Table ToStyle {style}  " Convert to specified style (updates the table option)
```

### :TableOption

Runtime configuration for the current buffer, changes do not persist across vim
sessions. Use without arguments to show current config.

```vim
:TableOption Style [name]                 " Get/set style
:TableOption Option [key] [value]         " Get/set option
:TableOption StyleOption [key] [value]    " Get/set style option
:TableOption RegisterStyle [name]         " Save current style (session only)
```

**Note:** Registering a style is only for the current session. Store them in
your vim/nvim config file to persist across sessions.

**Common options:**

| Option                 | Default | Description                                |
|------------------------|---------|--------------------------------------------|
| `multiline`            | false   | Allow cells to contain newlines            |
| `default_alignment`    | left    | Default column alignment: `l`, `c`, or `r` |
| `preserve_indentation` | true    | Keep leading whitespace in multiline cell  |

**Built-in styles:** `default`, `markdown`, `org`, `rest`, `single`, `double`

Example: `:TableOption Style markdown | :TableOption Option multiline true`

See `:help table-commands` and `:help table-styles` for details.

## Keybindings

Auto-alignment, navigational, and text object keybindings are mapped by default.
<Plug> mappings are available. Keybindings for table actions are not provided
but can be added easily:

```vim
" Example mappings (add to vimrc/init.vim)
nnoremap <leader>ta    <Plug>(table_align)
nnoremap <leader><bar> <Plug>(table_complete)
nnoremap <leader>td    <Plug>(table_to_default)
nnoremap <leader>te    <Plug>(table_cell_edit)
```

## Limitations

- Border characters in cells can not be parsed (pipes `|` cannot be cell content
        if it is also used as the `i_vertical` border character).
- No merged/spanning cells (multiline rows are supported)
- `i_vertical` and `i_horizontal` must be different characters

## License

Mozilla Public License 2.0 - See [LICENSE](LICENSE)

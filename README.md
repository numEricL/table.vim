# table.vim

Text table manipulation for Vim and Neovim.

## Quick Start

Type tables using pipes (`|`) and dashes (`-`). The table is aligned and redrawn
with the chosen style characters automatically when pipes are typed on tables
with at least two rows. Perform this action manually with the `:Table Align`
command.

Use the `:Table Complete` command fill missing cells and borders.

## Navigation

- `<Tab>` / `<S-Tab>` - Move to next/previous cell (wraps to next/previous row)
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Move left/down/up/right between cells
- Counts work: `3<Tab>` moves three cells forward

## Text Objects

Cell, row, and column text objects work in visual and operator-pending modes. By
default the text objects select half borders, use the "around" and "inner"
variants for full borders or no borders respectively.

| Object     | Description                   | Example                    |
|------------|-------------------------------|----------------------------|
| `tx/ix/ax` | half-open/inner/around cell   | `cix` change cell content  |
| `tr/ir/ar` | half-open/inner/around row    | `dtr` delete row           |
| `tc/ic/ac` | half-open/inner/around column | `yac` yank bordered-column |

Counts work: `d2tc` deletes two columns.

See `:help table-text-objects` for details.

## Cell Editing (Neovim only)

Cells may be edited in a floating window with the `:Table EditCell` command. The
window resizes automatically as you type. Close or leave the window to save
changes. Especially useful for multiline cells.

**Events:** `TableCellEditPre` and `TableCellEditPost` autocommands let you
customize editing behavior. See `:help table-events`.

## Configuration

### Setup Function (Optional)

Table.vim uses a default setup which can be overridden by calling the setup
function with a configuration table. Default mappings can be disabled with the
`disable_mappings` or by setting `g:table_disable_mappings` before the
`VimEnter` event.

- **Neovim (Lua):** `require('table_vim').setup({ ... })`
- **Vim (VimScript):** `call table#Setup({ ... })`

See `:help table-configuration` for complete setup documentation and all
available options.

### Runtime Commands

Table.vim provides two main commands:

#### :Table - Actions

```vim
:Table EditCell        " Edit current cell in floating window (Neovim only)
:Table Complete   " Complete table structure with borders
:Table Align      " Align table columns
:Table ToDefault       " Convert table to default style
```

### Keybindings

Table.vim provides a default mapping for auto-alignment: typing `|` in insert 
mode automatically aligns the table.

<Plug> mappings are provided for table actions (EditCell, Align,
Complete, ToDefault) but not mapped by default. You can map them in
your vim/nvim configuration as desired.

**Example keybindings** (add to your vimrc/init.vim):

```vim
" Table actions
nnoremap <leader>ta    <Plug>(table_align)
nnoremap <leader><bar> <Plug>(table_complete)
nnoremap <leader>td    <Plug>(table_to_default)

" Cell editing (Neovim only)
if has('nvim')
    nnoremap <leader>te <Plug>(table_cell_edit)
endif
```

**Default mappings:**
- `|` in insert mode - Auto-align table
- `<Tab>` / `<S-Tab>` - Navigate cells forward/backward
- `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` - Navigate cells directionally
- Text objects: `tx/ix/ax`, `tr/ir/ar`, `tc/ic/ac`

#### :TableOption - Configuration

```vim
:TableOption                           " Show current configuration
:TableOption Option [key] [value]      " Get or set an option
:TableOption Style [name]              " Get or set style
:TableOption StyleOption [key] [value] " Get or set style option
:TableOption RegisterStyle [name]      " Save current style as custom style
```

**Note:** Custom style are saved only for the current session. Store them in
your vim/nvim config file to persist across sessions.


Common options:

| Option                 | Default | Description                                |
|------------------------|---------|--------------------------------------------|
| `multiline`            | false   | Allow cells to contain newlines            |
| `default_alignment`    | left    | Default column alignment: `l`, `c`, or `r` |
| `preserve_indentation` | true    | Keep leading whitespace in multiline cell  |

Built-in styles: `default`, `markdown`, `orgmode`, `rest`, `single`, `double`

Example runtime configuration:
```vim
:TableOption Style markdown
:TableOption Option multiline true
:TableOption StyleOption omit_left_border true
```

See `:help table-commands` and `:help table-styles` for details.

## Limitations

- **Border characters in cells**: The parser does not differentiate between
border characters (e.g., `i_vertical`) inside cells versus as actual borders. By
default, pipes (`|`) cannot be used as cell content.
- **No merged/spanning cells**: While multiline rows are fully supported, merged
or spanning cells across columns are not supported.
- **Border character constraints**: `i_vertical` and `i_horizontal` must be
different characters. Tables where all border characters are the same (e.g., all
`#`) are not supported.

## License

Mozilla Public License 2.0 - See [LICENSE](LICENSE)

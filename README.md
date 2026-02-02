# table.vim

Text table manipulation for Vim and Neovim.

## Quick Start

Type tables using pipes (`|`) and dashes (`-`). The table is aligned and borders
drawn automatically when pipes are typed on tables with at least two rows.

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
| `tx/ix/ax` | nice                          | `cix` change cell content  |
| `tr/ir/ar` | half-open/inner/around row    | `dtr` delete row           |
| `tc/ic/ac` | half-open/inner/around column | `yac` yank bordered-column |

Counts work: `d2tc` deletes two columns.

See `:help table-text-objects` for details.

## Cell Editing (Neovim only)

`<Leader>te` opens a floating window to edit the cell under the cursor. The
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

Use `:Table` subcommands to view or change configuration at runtime:

```vim
:Table                           " Show current configuration
:Table Option [key] [value]      " Get or set an option
:Table Style [name]              " Get or set style
:Table StyleOption [key] [value] " Get or set style option
:Table RegisterStyle [name]      " Save current style as custom style
```

Common options:

| Option                 | Default | Description                                |
|------------------------|---------|--------------------------------------------|
| `multiline`            | false   | Allow cells to contain newlines            |
| `default_alignment`    | left    | Default column alignment: `l`, `c`, or `r` |
| `preserve_indentation` | true    | Keep leading whitespace in multiline cell  |

Built-in styles: `default`, `markdown`, `orgmode`, `rest`, `single`, `double`

Example runtime configuration:
```vim
:Table Style markdown
:Table Option multiline true
:Table StyleOption omit_left_border true
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

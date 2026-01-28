" Fancy table styles for table.vim
" ONLY THE EXCITING ONES - NO BORING TABLES ALLOWED!

" Heavy style - all heavy box drawing characters for maximum impact
let s:heavy = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '┣',
            \   'align_right'  : '┫',
            \   'align_sep'    : '╋',
            \   'align_horiz'  : '━',
            \   'sep_left'     : '┣',
            \   'sep_right'    : '┫',
            \   'sep_sep'      : '╋',
            \   'sep_horiz'    : '━',
            \   'top_left'     : '┏',
            \   'top_right'    : '┓',
            \   'top_sep'      : '┳',
            \   'top_horiz'    : '━',
            \   'bottom_left'  : '┗',
            \   'bottom_right' : '┛',
            \   'bottom_sep'   : '┻',
            \   'bottom_horiz' : '━',
            \   'row_left'     : '┃',
            \   'row_right'    : '┃',
            \   'row_sep'      : '┃',
            \   }
            \ }

" Neon style - uses block elements and special characters for a retro-futuristic look
let s:neon = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '▓',
            \   'align_right'  : '▓',
            \   'align_sep'    : '▓',
            \   'align_horiz'  : '▀',
            \   'sep_left'     : '▓',
            \   'sep_right'    : '▓',
            \   'sep_sep'      : '▓',
            \   'sep_horiz'    : '▀',
            \   'top_left'     : '▛',
            \   'top_right'    : '▜',
            \   'top_sep'      : '▀',
            \   'top_horiz'    : '▀',
            \   'bottom_left'  : '▙',
            \   'bottom_right' : '▟',
            \   'bottom_sep'   : '▄',
            \   'bottom_horiz' : '▄',
            \   'row_left'     : '▐',
            \   'row_right'    : '▌',
            \   'row_sep'      : '│',
            \   }
            \ }

" Thick style - extremely bold using full-width characters
let s:thick = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '▐',
            \   'align_right'  : '▌',
            \   'align_sep'    : '▌',
            \   'align_horiz'  : '▬',
            \   'sep_left'     : '▐',
            \   'sep_right'    : '▌',
            \   'sep_sep'      : '▌',
            \   'sep_horiz'    : '▬',
            \   'top_left'     : '▛',
            \   'top_right'    : '▜',
            \   'top_sep'      : '▀',
            \   'top_horiz'    : '▀',
            \   'bottom_left'  : '▙',
            \   'bottom_right' : '▟',
            \   'bottom_sep'   : '▄',
            \   'bottom_horiz' : '▄',
            \   'row_left'     : '█',
            \   'row_right'    : '█',
            \   'row_sep'      : '█',
            \   }
            \ }

" Dotted style - uses dots and circles for a decorative look
let s:dotted = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '◉',
            \   'align_right'  : '◉',
            \   'align_sep'    : '◉',
            \   'align_horiz'  : '·',
            \   'sep_left'     : '○',
            \   'sep_right'    : '○',
            \   'sep_sep'      : '○',
            \   'sep_horiz'    : '·',
            \   'top_left'     : '●',
            \   'top_right'    : '●',
            \   'top_sep'      : '●',
            \   'top_horiz'    : '·',
            \   'bottom_left'  : '●',
            \   'bottom_right' : '●',
            \   'bottom_sep'   : '●',
            \   'bottom_horiz' : '·',
            \   'row_left'     : '┊',
            \   'row_right'    : '┊',
            \   'row_sep'      : '┊',
            \   }
            \ }

" Stars style - cosmic theme with stars and sparkles
let s:stars = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '★ ',
            \   'align_right'  : '★ ',
            \   'align_sep'    : '✦ ',
            \   'align_horiz'  : '─',
            \   'sep_left'     : '✦ ',
            \   'sep_right'    : '✦ ',
            \   'sep_sep'      : '✧ ',
            \   'sep_horiz'    : '─',
            \   'top_left'     : '✶',
            \   'top_right'    : '✶',
            \   'top_sep'      : '✵ ',
            \   'top_horiz'    : '═',
            \   'bottom_left'  : '✶',
            \   'bottom_right' : '✶',
            \   'bottom_sep'   : '✵ ',
            \   'bottom_horiz' : '═',
            \   'row_left'     : '║',
            \   'row_right'    : '║',
            \   'row_sep'      : '│',
            \   }
            \ }

" Arrows style - dynamic directional theme
let s:arrows = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '◄',
            \   'align_right'  : '►',
            \   'align_sep'    : '◆',
            \   'align_horiz'  : '═',
            \   'sep_left'     : '◄',
            \   'sep_right'    : '►',
            \   'sep_sep'      : '◆',
            \   'sep_horiz'    : '─',
            \   'top_left'     : '▲',
            \   'top_right'    : '▲',
            \   'top_sep'      : '▲',
            \   'top_horiz'    : '─',
            \   'bottom_left'  : '▼',
            \   'bottom_right' : '▼',
            \   'bottom_sep'   : '▼',
            \   'bottom_horiz' : '─',
            \   'row_left'     : '║',
            \   'row_right'    : '║',
            \   'row_sep'      : '│',
            \   }
            \ }

" Wave style - flowing, organic curves
let s:wave = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '≋',
            \   'align_right'  : '≋',
            \   'align_sep'    : '≋',
            \   'align_horiz'  : '≈',
            \   'sep_left'     : '〜',
            \   'sep_right'    : '〜',
            \   'sep_sep'      : '〜',
            \   'sep_horiz'    : '～',
            \   'top_left'     : '╭',
            \   'top_right'    : '╮',
            \   'top_sep'      : '∿',
            \   'top_horiz'    : '∼',
            \   'bottom_left'  : '╰',
            \   'bottom_right' : '╯',
            \   'bottom_sep'   : '∿',
            \   'bottom_horiz' : '∼',
            \   'row_left'     : '⋮',
            \   'row_right'    : '⋮',
            \   'row_sep'      : '⋮',
            \   }
            \ }

" Grid style - hashtag/grid pattern
let s:grid = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '#',
            \   'align_right'  : '#',
            \   'align_sep'    : '#',
            \   'align_horiz'  : '#',
            \   'sep_left'     : '#',
            \   'sep_right'    : '#',
            \   'sep_sep'      : '#',
            \   'sep_horiz'    : '#',
            \   'top_left'     : '#',
            \   'top_right'    : '#',
            \   'top_sep'      : '#',
            \   'top_horiz'    : '#',
            \   'bottom_left'  : '#',
            \   'bottom_right' : '#',
            \   'bottom_sep'   : '#',
            \   'bottom_horiz' : '#',
            \   'row_left'     : '#',
            \   'row_right'    : '#',
            \   'row_sep'      : '#',
            \   }
            \ }

" Underwater style - oceanic theme with waves and aquatic elements
let s:underwater = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '≋',
            \   'align_right'  : '≋',
            \   'align_sep'    : '⋈',
            \   'align_horiz'  : '≈',
            \   'sep_left'     : '⋮',
            \   'sep_right'    : '⋮',
            \   'sep_sep'      : '•',
            \   'sep_horiz'    : '∼',
            \   'top_left'     : '╭',
            \   'top_right'    : '╮',
            \   'top_sep'      : '○',
            \   'top_horiz'    : '~',
            \   'bottom_left'  : '╰',
            \   'bottom_right' : '╯',
            \   'bottom_sep'   : '○',
            \   'bottom_horiz' : '~',
            \   'row_left'     : '⋮',
            \   'row_right'    : '⋮',
            \   'row_sep'      : '┊',
            \   }
            \ }

" Art Deco style - 1920s geometric elegance with maximum bling
let s:artdeco = {
            \ 'options' : {
            \   'omit_left_border'     : v:false,
            \   'omit_right_border'    : v:false,
            \   'omit_top_border'      : v:false,
            \   'omit_bottom_border'   : v:false,
            \   'omit_separator_rows'  : v:false,
            \ },
            \ 'box_drawing' : {
            \   'align_left'   : '◆',
            \   'align_right'  : '◆',
            \   'align_sep'    : '◈',
            \   'align_horiz'  : '▬',
            \   'sep_left'     : '▐',
            \   'sep_right'    : '▌',
            \   'sep_sep'      : '┃',
            \   'sep_horiz'    : '─',
            \   'top_left'     : '▛',
            \   'top_right'    : '▜',
            \   'top_sep'      : '▀',
            \   'top_horiz'    : '▀',
            \   'bottom_left'  : '▙',
            \   'bottom_right' : '▟',
            \   'bottom_sep'   : '▄',
            \   'bottom_horiz' : '▄',
            \   'row_left'     : '▐',
            \   'row_right'    : '▌',
            \   'row_sep'      : '┃',
            \   }
            \ }

function! table#style#fancy#Register() abort
    call table#style#Register('heavy', s:heavy)
    call table#style#Register('neon', s:neon)
    call table#style#Register('thick', s:thick)
    call table#style#Register('dotted', s:dotted)
    call table#style#Register('stars', s:stars)
    call table#style#Register('arrows', s:arrows)
    call table#style#Register('wave', s:wave)
    call table#style#Register('grid', s:grid)
    call table#style#Register('underwater', s:underwater)
    call table#style#Register('artdeco', s:artdeco)
endfunction

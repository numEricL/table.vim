let s:save_cpo = &cpo
set cpo&vim

function! table#sort#Sort(table, dim_kind, id, flags) abort
    if a:dim_kind ==# 'rows'
        call s:SortRows(a:table, a:id, a:flags)
    elseif a:dim_kind ==# 'cols'
        call s:SortCols(a:table, a:id, a:flags)
    else
        throw "Invalid dim_kind: " .. string(a:dim_kind)
    endif
endfunction

function! s:SortRows(table, col_id, flags) abort
    if a:col_id < 0 || a:col_id >= a:table.ColCount()
        throw "col_id out of range"
    endif

    " remove the header row
    let tagged_cells = copy(a:table.rows)
    call remove(tagged_cells, 0)
    let temp_rows = copy(tagged_cells)

    " compute the permutation from sorting column col_id
    let tagged_cells = map(tagged_cells, {id, row -> [ join(row.cells[a:col_id], "\n"), id ] })
    let VimSortHow = s:GetVimSortHow(a:flags)
    call sort(tagged_cells, VimSortHow)
    let permutation = map(copy(tagged_cells), {_, v -> v[1]})
    if index(a:flags, '!') != -1
        call reverse(permutation)
    endif

    "sort the non-header rows according to the permutation
    for i in range(len(temp_rows))
        let a:table.rows[i+1] = temp_rows[permutation[i]]
    endfor
endfunction

function! s:SortCols(table, row_id, flags) abort
    if a:row_id < 0 || a:row_id >= a:table.RowCount()
        throw "row_id out of range"
    endif

    let tagged_cells = copy(a:table.rows[a:row_id].cells)
    " compute the permutation from sorting column col_id
    let tagged_cells = map(tagged_cells, {id, cell -> [ trim(join(cell, "\n")), id ] })
    let VimSortHow = s:GetVimSortHow(a:flags)
    call sort(tagged_cells, VimSortHow)
    let permutation = map(copy(tagged_cells), {_, v -> v[1]})
    if index(a:flags, '!') != -1
        call reverse(permutation)
    endif

    let col_align    = []
    let fixed_widths = []
    for i in range(a:table.ColCount())
        call add(col_align,    get(a:table.col_align,    i, ''))
        call add(fixed_widths, get(a:table.fixed_widths, i, 0 ))
    endfor
    let a:table.col_align    = s:Permute(col_align,    permutation)
    let a:table.fixed_widths = s:Permute(fixed_widths, permutation)
    for i in range(len(a:table.rows))
        let a:table.rows[i].cells = s:Permute(a:table.rows[i].cells, permutation)
    endfor
endfunction

" script local s:Op and s:LessThan used to avoid memory leaks from referencing the
" closure the in the context it depends on. See :help lambda
function! s:GetVimSortHow(flags) abort
    let s:Op = ''
        if index(a:flags, 'i') != -1 | let s:Op = { x ->   tolower(x[0]) }
    elseif index(a:flags, 'n') != -1 | let s:Op = { x ->    str2nr(x[0]) }
    elseif index(a:flags, 'f') != -1 | let s:Op = { x -> str2float(x[0]) }
    else 
        let s:Op = { x -> x[0] }
    endif
    let s:LessThan = ''
    if index(a:flags, 'c') != -1
        let cfg_opts = table#config#Config(bufnr('%')).options
        let s:LessThan = cfg_opts.SortComparator
        if type(s:LessThan) != v:t_func
            throw "Invalid sort comparator: " .. string(s:LessThan)
        endif
    else
        let s:LessThan = { a,b -> a <# b }
    endif
    return { a,b -> s:LessThan(s:Op(a),s:Op(b)) ? -1 : s:LessThan(s:Op(b),s:Op(a)) ? 1 : 0 }
endfunction

function! s:Permute(list, permutation) abort
    let temp = copy(a:list)
    for i in range(len(a:list))
        let temp[i] = a:list[a:permutation[i]]
    endfor
    return temp
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

let s:save_cpo = &cpo
set cpo&vim

function table#sort#Sort(table, dim_kind, id, flags) abort
    if a:dim_kind ==# 'rows'
        call s:SortRows(a:table, a:id, a:flags)
    elseif a:dim_kind ==# 'cols'
        call s:SortCols(a:table, a:id, a:flags)
    else
        throw "Invalid dim_kind: %s" .. string(a:dim_kind)
    endif
endfunction

function s:SortRows(table, col_id, flags) abort
    " remove the header row
    let tagged_cells = copy(a:table.rows)
    call remove(tagged_cells, 0)
    let temp_rows = copy(tagged_cells)

    " compute the permutation from sorting column col_id
    let tagged_cells = map(tagged_cells, {id, row -> [ join(row.cells[a:col_id], "\n"), id ] })
    let Vim_sort_how = s:GetVimSortHow(a:flags)
    if Vim_sort_how ==# 'f'
        call map(tagged_cells, {_, v -> [ str2float(v[0]), v[1] ] })
    endif
    call sort(tagged_cells, Vim_sort_how)
    let permutation = map(copy(tagged_cells), {_, v -> v[1]})
    if index(a:flags, '!') != -1
        call reverse(permutation)
    endif

    "sort the non-header rows according to the permutation
    for i in range(len(temp_rows))
        let a:table.rows[i+1] = temp_rows[permutation[i]]
    endfor
endfunction

function s:SortCols(table, row_id, flags) abort
    let tagged_cells = copy(a:table.rows[a:row_id].cells)
    " compute the permutation from sorting column col_id
    let tagged_cells = map(tagged_cells, {id, cell -> [ join(cell, "\n"), id ] })
    let Vim_sort_how = s:GetVimSortHow(a:flags)
    if Vim_sort_how == 'f'
        call map(tagged_cells, {_, v -> [ str2float(v[0]), v[1] ] })
    endif
    call sort(tagged_cells, Vim_sort_how)
    let permutation = map(copy(tagged_cells), {_, v -> v[1]})
    if index(a:flags, '!') != -1
        call reverse(permutation)
    endif

    "sort the cols according to the permutation
    for i in range(len(a:table.rows))
        let temp_row_cells = copy(a:table.rows[i].cells)
        for j in range(a:table.rows[i].ColCount())
            let a:table.rows[i].cells[j] = temp_row_cells[permutation[j]]
        endfor
    endfor
endfunction

function s:GetVimSortHow(flags) abort
    let Op = { x -> x[0] }

        if index(a:flags, 'i') != -1 | let Op = { x -> tolower(x[0]) }
    elseif index(a:flags, 'n') != -1 | let Op = { x -> str2nr(x[0]) }
    elseif index(a:flags, 'f') != -1 | let Op = { x -> str2float(x[0]) }
    elseif index(a:flags, 'c') != -1
        let cfg_opts = table#config#Config(bufnr('%')).options
        if type(cfg_opts.SortComparator) == v:t_func
            " cfg_opts.SortComparator is assumed to be a LessThan func
            return { a,b -> cfg_opts.SortComparator(a[0],b[0])? -1 : cfg_opts.SortComparator(b[0],a[0])? 1 : 0 }
        endif
    endif
    return { a,b -> Op(a) < Op(b) ? -1 : Op(b) < Op(a) ? 1 : 0 }
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

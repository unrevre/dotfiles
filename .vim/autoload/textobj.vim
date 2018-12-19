function! textobj#select(begin, end) abort
    if (a:begin != a:end) && (a:end != [0, 0])
        call cursor(a:begin)
        normal v
        call cursor(a:end)
    endif
endfunction

function! textobj#cancel() abort
    if v:operator == 'c'
        augroup emptyobj
            autocmd InsertLeave <buffer> execute 'normal! u'
                    \ | execute 'autocmd! emptyobj'
                    \ | execute 'augroup! emptyobj'
        augroup END
    endif
endfunction

function! textobj#indent(ext) abort
    while empty(getline('.'))
        execute 'normal! -'
    endwhile
    normal! ^
    let l:i = virtcol(getline('.') =~# '^\s*$' ? '$' : '.')

    let l:pat = '^\(\s*\%'.l:i.'v\|^$\)\@!'
    let l:start = search(l:pat, 'bWn') + 1
    let l:end = search(l:pat, 'Wn')
    if (l:end !=# 0) | let l:end -= 1 | endif
    if a:ext
        execute 'normal! '.l:start.'G0'
        call search('^[^\n\r]', 'bW')
        execute 'normal! Vo'.l:end.'G'
        call search('^[^\n\r]', 'W')
        normal! $o
    else
        execute 'normal! '.l:start.'G0V'.l:end.'G$o'
    endif
endfunction

function! textobj#comment(vis) abort
    if synIDattr(synID(line('.'), col('.'), 0), 'name') !~? 'comment'
        call textobj#cancel()
        if a:vis | execute 'normal! gv' | endif
        return
    endif

    let origin = line('.')
    let lines = []
    for dir in [-1, 1]
        let line = origin + dir
        while line >= 1 && line <= line('$')
            execute 'normal!' line.'G^'
            if synIDattr(synID(line('.'), col('.'), 0), 'name') !~? 'comment'
                break
            endif
            let line += dir
        endwhile
        call add(lines, line - dir)
    endfor

    execute 'normal!' lines[0].'GV'.lines[1].'G'
endfunction

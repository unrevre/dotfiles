function! util#repeat(...) abort
    execute (a:0 ? "'[,']" : "'<,'>").'normal @'.nr2char(getchar())
endfunction

function! util#break() abort
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction

function! util#indent_len(str) abort
    return type(a:str) == 1 ? len(matchstr(a:str, '^\s*')) : 0
endfunction

function! util#next_indent(times, dir) abort
    for _ in range(a:times)
        let l = line('.')
        let x = line('$')
        let i = util#indent_len(getline(l))
        let e = empty(getline(l))

        while l >= 1 && l <= x
            let line = getline(l + a:dir)
            let l += a:dir
            if util#indent_len(line) != i || empty(line) != e
                break
            endif
        endwhile
        let l = min([max([1, l]), x])
        execute 'normal! '. l .'G^'
    endfor
endfunction

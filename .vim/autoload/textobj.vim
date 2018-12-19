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

function! textobj#indent(b, e, ext) abort
    let i = min([util#indent_len(getline(a:b)), util#indent_len(getline(a:e))])
    let x = line('$')
    let d = [a:b, a:e]

    if i == 0 && empty(getline(a:b)) && empty(getline(a:e))
        let [b, e] = [a:b, a:e]
        while b > 0 && e <= line('$')
            let b -= 1 | let e += 1
            let i = min(filter(map([b, e], 'util#indent_len(getline(v:val))'),
                        \'v:val != 0'))
            if i > 0 | break | endif
        endwhile
    endif

    for triple in [[0, 'd[o] > 1', -1], [1, 'd[o] < x', +1]]
        let [o, ev, df] = triple
        while eval(ev)
            let line = getline(d[o] + df)
            let idt = util#indent_len(line)
            if idt >= i || empty(line) | let d[o] += df
            else | break | end
        endwhile
    endfor
    execute printf('normal! %dGV%dG', max([1, d[0] - a:ext]), min([x, d[1] + a:ext]))
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

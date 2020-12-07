function! util#repeat(...) abort
    execute (a:0 ? "'[,']" : "'<,'>").'normal @'.nr2char(getchar())
endfunction

function! util#break() abort
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction

function! util#makefile() abort
    let files = split(substitute(system('ls'), 'make', 'Make', 'g'))
    if index(files, 'Makefile') >= 0
        let &l:makeprg = 'make'
    endif
endfunction

function! util#togglelint() abort
    if exists('#lint#BufWritePost')
        augroup lint
            autocmd!
        augroup END
    else
        augroup lint
            autocmd!
            autocmd BufWritePost *.S,*.c,*.cpp,*.py Make!
        augroup END
    endif
endfunction

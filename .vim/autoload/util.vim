function! util#repeat(...) abort
    execute (a:0 ? "'[,']" : "'<,'>").'normal @'.nr2char(getchar())
endfunction

function! util#break() abort
    s/^\(\s*\)\(.\{-}\)\(\s*\)\(\%#\)\(\s*\)\(.*\)/\1\2\r\1\4\6
    call histdel("/", -1)
endfunction

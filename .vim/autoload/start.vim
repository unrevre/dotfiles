function! start#guess()
    let view = winsaveview()
    silent! 0/^\t\%(\s*$\)\@!/
    let tabs = getline('.') =~ '^\t\%(\s*$\)\@!'
    silent! 0/^ \{2,8}\S/
    let spaceshort = len(matchstr(getline('.'), '^ \{2,8}\ze\S'))
    silent! 0/^ \+\S.*\n\%(\s*\n)*\t/
    let spacelong = len(matchstr(getline('.'),
            \ '^ \+\ze\S.*\n\%(\s*\n\)*\t'))
    let &l:sw = spaceshort ? spaceshort : (tabs ? 0 : &sw)
    let &l:sts = -1
    let &l:et = !tabs
    let ts = spaceshort + spacelong
    let &l:ts = ts%4 || ts<=&l:sw ? 8 : ts
    call winrestview(view)
endfunction

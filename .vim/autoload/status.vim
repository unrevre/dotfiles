function! s:Colour(active, group, content) abort
    let higroup = a:active ? a:group : 6
    return '%' . higroup . '*' . a:content
endfunction

function! s:Mode() abort
    let m = mode()
    if m ==# 'n'
        return 1
    elseif m ==? 'v' || m ==? "\<C-v>"
        return 4
    elseif m ==? 's' || m ==? "\<C-s>"
        return 5
    elseif m ==# 'i'
        return 2
    elseif m ==# 'R'
        return 3
    else
        return 7
    endif
endfunction

function! status#line(win) abort
    let active = a:win == winnr()

    let stat = ''
    let stat .= s:Colour(active, s:Mode(), '%( %3l %)')
    let stat .= s:Colour(active, 6, '%( %<%f%m %r %)')
    let stat .= '%='
    let stat .= s:Colour(active, 6, '%( %{git#branch()} %)')
    let stat .= s:Colour(active, 7, '%( %2c %)')

    return stat
endfunction

function! status#refresh() abort
    for nr in range(1, winnr('$'))
        call setwinvar(nr, '&statusline', '%!status#line(' . nr . ')')
    endfor
endfunction

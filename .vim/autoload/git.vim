function! git#dir(path) abort
    let path = a:path
    let prev = ''
    while path !=# prev
        let dir = path . '/.git'
        let type = getftype(dir)
        if type ==# 'dir' && isdirectory(dir.'/objects') && isdirectory(dir.'/refs') && getfsize(dir.'/HEAD') > 10
            return dir
        elseif type ==# 'file'
            let reldir = get(readfile(dir), 0, '')
            if reldir =~# '^gitdir: '
                return simplify(path . '/' . reldir[8:])
            endif
        endif
        let prev = path
        let path = fnamemodify(path, ':h')
    endwhile
    return ''
endfunction

function! git#detect(path) abort
    unlet! b:gitbranch_path
    let b:gitbranch_pwd = expand('%:p:h')
    let dir = git#dir(a:path)
    if dir !=# ''
        let path = dir . '/HEAD'
        if filereadable(path)
            let b:gitbranch_path = path
            let b:gitdir_path = dir
        endif
    endif
endfunction

function! git#branch() abort
    if get(b:, 'gitbranch_pwd', '') !=# expand('%:p:h') || !has_key(b:, 'gitbranch_path')
        call git#detect(expand('%:p:h'))
    endif
    if has_key(b:, 'gitbranch_path') && filereadable(b:gitbranch_path)
        let branch = get(readfile(b:gitbranch_path), 0, '')
        if branch =~# '^ref: '
            return substitute(branch, '^ref: \%(refs/\%(heads/\|remotes/\|tags/\)\=\)\=', '', '')
        elseif branch =~# '^\x\{20\}'
            return branch[:6]
        endif
    endif
    return ''
endfunction

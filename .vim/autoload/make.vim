let s:jobinfo = {}

function! s:Expand(input)
    let l:split_input = split(a:input)
    let l:expanded_input = []
    for l:token in l:split_input
        if l:token =~ '^\\\?%\|^\\\?#\|^\\\?\$' && l:token != '$*' &&
                \ expand(l:token) != ''
            let l:expanded_input += [expand(l:token)]
        else
            let l:expanded_input += [l:token]
        endif
    endfor
    return join(l:expanded_input)
endfunction

function! s:InitAutocmd(cmd)
    let l:returnval = 'doautocmd QuickFixCmd'.a:cmd.' make'
    return l:returnval
endfunction

function! s:CreateBuffer(prog)
    silent execute 'belowright 10split '.a:prog
    setlocal bufhidden=hide buftype=nofile buflisted nolist
    setlocal noswapfile nowrap nomodifiable
    nmap <buffer> <C-c> :MakeStop<CR>
    let l:bufnum = winbufnr(0)
    wincmd p
    return l:bufnum
endfunction

function! s:JobHandler(channel) abort
    let l:job = remove(s:jobinfo, split(a:channel)[1])

    let l:curwinnr = winnr()
    execute bufwinnr(l:job['srcbufnr']).'wincmd w'
    unlet b:makejob
    nunmap <buffer> <C-c>

    if bufwinnr(l:job['outbufnr'])
        silent execute bufwinnr(l:job['outbufnr']).'close'
    endif
    silent execute 'cgetbuffer '.l:job['outbufnr']
    silent execute l:job['outbufnr'].'bwipe!'
    execute l:curwinnr.'wincmd w'

    let l:idx = 0
    let l:makeoutput = 0
    let l:initqf = getqflist()
    while l:idx < len(l:initqf)
        let l:qfentry = l:initqf[l:idx]
        if l:qfentry['valid']
            let l:makeoutput += 1
        endif
        let l:idx += 1
    endwhile

    silent execute s:InitAutocmd('Post')

    if l:job['cfirst']
        silent! cfirst
    end

    echomsg l:job['prog']." ended with ".l:makeoutput." findings"
endfunction

function! make#make(bang, ...) abort
    let l:make = s:Expand(&makeprg)
    let l:prog = split(l:make)[0]
    execute 'let l:openbufnr = bufnr("^'.l:prog.'$")'
    if l:openbufnr != -1
        echohl WarningMsg
        echomsg l:prog.' already running'
        echohl None
        return
    endif
    "  Check for whitespace inputs/no input
    if a:0 && (a:1 != '')
        let l:arg = substitute(a:1, '^\s\+\|\s\+$', '', 'g')

        if l:make =~ '\$\*'
            let l:make = substitute(l:make, '\$\*', l:arg, 'g')
        else
            let l:make = l:make.' '.l:arg
        endif

        let l:make = [&shell, &shellcmdflag, l:make]
    endif

    let l:opts = { 'close_cb' : function('s:JobHandler'),
            \  'out_io': 'buffer',
            \  'out_name': l:prog,
            \  'out_modifiable': 0,
            \  'err_io': 'buffer',
            \  'err_name': l:prog,
            \  'err_modifiable': 0,
            \  'in_io': 'null'}

    silent execute s:InitAutocmd('Pre')

    if &autowrite && !empty(bufname('%'))
        silent write
    endif

    let l:outbufnr = s:CreateBuffer(prog)

    let l:makejob = job_start(l:make, l:opts)
    let b:makejob = l:makejob
    let s:jobinfo[split(job_getchannel(b:makejob))[1]] =
            \ { 'prog': l:prog,
            \   'outbufnr': l:outbufnr,
            \   'srcbufnr': winbufnr(0),
            \   'cfirst': !a:bang,
            \   'job': b:makejob, }
    echomsg s:jobinfo[split(job_getchannel(b:makejob))[1]]['prog']
            \ .' started'

    execute bufwinnr(l:outbufnr).'wincmd w'
    let b:makejob = l:makejob
    wincmd p
    nmap <buffer> <C-c> :MakeStop<CR>
endfunction

function! make#stop(...) abort
    if a:0
       if bufexists(a:1)
           execute bufwinnr(a:1).'wincmd w'
           if exists('b:makejob')
               if !job_stop(b:makejob)
                   echoerr 'Failed to stop current Make'
               end
           else
               echoerr 'Provided buffer is not a Make'
           end
           wincmd p
       else
           echoerr 'Provided Make does not exist'
       endif
    elseif exists('b:makejob')
       let l:job = s:jobinfo[split(job_getchannel(b:makejob))[1]]
       if !job_stop(b:makejob)
           echoerr 'Failed to stop '.l:job['prog']
       endif
    else
        echoerr 'Not in a Make buffer, and none specified'
    endif
endfunction

function! make#completion(arglead, cmdline, cursorpos)
    let l:return = []
    for l:key in keys(s:jobinfo)
        let l:return += [s:jobinfo[l:key]['prog']]
    endfor
    return l:return
endfunction

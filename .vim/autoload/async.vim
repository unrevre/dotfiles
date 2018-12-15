func! s:finalize(scope, prefix, settitle) abort
    let l:job = get(a:scope, 'async')
    if type(l:job) isnot v:t_dict | return | endif
    try
        exe a:prefix.(l:job.jump ? '' : 'get').'file '.l:job.file
        call a:settitle(l:job.cmd, l:job.nr)
    finally
        unlet! a:scope.async
        call delete(l:job.file)
    endtry
endfunc

func! s:nameexpand(str) abort
    return substitute(a:str, '\v\\=%(\%|\#)%(\:[phrte])*', {a->expand(a[0])}, 'g')
endfunc

func! s:slashescape(str) abort
    return substitute(a:str, '\\', '\\\\\\', 'g')
endfunc

func! s:escape(str) abort
    return s:slashescape(s:nameexpand(a:str))
endfunc

func! s:build(scope, prefix, settitle) abort
    function! Run(nojump, cmd, ...) abort closure
        if type(get(a:scope, 'async')) == v:t_dict
            echoerr 'wait for existing job' | return
        endif

        let l:job = {}
        let l:cmd = a:cmd

        call extend(l:job, {'nr': win_getid(), 'file': tempname(), 'jump': !a:nojump})
        let l:args = copy(a:000)
        if l:cmd =~# '\$\*'
            let l:job.cmd = substitute(l:cmd, '\$\*', join(l:args), 'g')
        else
            let l:job.cmd = join([s:escape(l:cmd)] + l:args)
        endif
        echom l:job.cmd
        let l:spec = [&shell, &shellcmdflag, l:job.cmd . printf(&shellredir, l:job.file)]
        let l:Callback = {-> s:finalize(a:scope, a:prefix, a:settitle)}

        let l:job.id = job_start(l:spec, {
                    \   'in_io': 'null','out_io': 'null','err_io': 'null',
                    \   'exit_cb': l:Callback
                    \ })
        let a:scope['async'] = l:job
    endfunc

    func! Stop() abort closure
        let l:job = get(a:scope, 'async')
        if type(l:job) is v:t_dict
            call job_stop(l:job.id)
            unlet! a:scope['async']
        endif
    endfunc

    return { 'run': funcref('Run'), 'stop': funcref('Stop') }
endfunc

let s:qf = s:build(g:, 'c', {title, nr -> setqflist([], 'a', {'title': title})})
let s:ll = s:build(w:, 'l', {title, nr -> setloclist(nr, [], 'a', {'title': title})})

func! async#run(...) abort
    call call(s:qf.run, a:000)
endfunc

func! async#stop(...) abort
    call call(s:qf.stop, a:000)
endfunc

func! async#lrun(...) abort
    call call(s:ll.run, a:000)
endfunc

func! async#lstop(...) abort
    call call(s:ll.stop, a:000)
endfunc

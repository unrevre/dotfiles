func! s:finalize(scope, prefix) abort
    let l:job = get(a:scope, 'job')
    if type(l:job) isnot v:t_dict | return | endif
    try
        exe a:prefix . 'file ' . l:job.file
    finally
        call delete(l:job.file)
        call filter(a:scope.ids, 'v:val != l:job.id')
        unlet! a:scope.job
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

func! s:build(scope, prefix) abort
    function! Run(cmd, ...) abort closure
        let l:job = {'nr': win_getid(), 'file': tempname()}

        let l:cmd = a:cmd
        let l:args = copy(a:000)
        let l:job.cmd = (l:cmd =~# '\$\*'
                    \? substitute(l:cmd, '\$\*', join(l:args), 'g')
                    \: join([s:escape(l:cmd)] + l:args))
        echom l:job.cmd

        let l:spec = [
                    \   &shell,
                    \   &shellcmdflag,
                    \   l:job.cmd . printf(&shellredir, l:job.file)
                    \]
        let l:Callback = {-> s:finalize(a:scope, a:prefix)}
        let l:job.id = job_start(l:spec, {
                    \   'in_io': 'null', 'out_io': 'null', 'err_io': 'null',
                    \   'exit_cb': l:Callback
                    \ })
        let a:scope.job = l:job

        let l:ids = add(get(a:scope, 'ids', []), l:job.id)
        let a:scope.ids = l:ids
    endfunc

    func! Stop(id) abort closure
        call job_stop(a:id)
        call filter(a:scope.ids, 'v:val != a:id')
    endfunc

    return { 'run': funcref('Run'), 'stop': funcref('Stop') }
endfunc

let s:qf = s:build(g:, 'c')
let s:ll = s:build(w:, 'l')

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

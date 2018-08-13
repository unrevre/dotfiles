execute pathogen#infect()

" vim-commentary
" vim-easyalign
" vim-peekaboo
" vim-surround
" vim-tradewinds
" vimagit

" general settings {
filetype plugin indent on
syntax on

colorscheme colours

set background=light
set encoding=utf-8

set tabstop=8
set shiftwidth=4
set smarttab
set expandtab
set autoindent

set ttimeout
set ttimeoutlen=10

set backspace=indent,eol,start
set formatoptions+=j
set nojoinspaces

set incsearch
set hlsearch
set noshowmode
set laststatus=2
set display+=lastline
set scrolloff=1
set fillchars=vert:\ ,fold:-

set hidden
set sessionoptions-=options
set history=512
set tabpagemax=16

set wildmenu

runtime macros/matchit.vim

let mapleader = ' '
let maplocalleader = ' '

let g:tex_flavor = "latex"
" }

" key bindings {
nnoremap <silent> <C-g> :let _s=@/ <Bar> :%s/\s\+$//e <Bar>
        \ :let @/=_s <Bar> :nohl <Bar> :unlet _s<CR>
nnoremap <silent> <C-l> :nohlsearch<C-r>=has('diff')?' <Bar>
        \ diffupdate':''<CR><CR><C-l>
nnoremap <silent> @R :set operatorfunc=util#repeat<CR>g@

nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprev<CR>
nnoremap ]t :tabn<CR>
nnoremap [t :tabp<CR>

nnoremap <silent> gb :<C-u>call util#break()<CR>
nnoremap <silent> gk :<C-u>call util#next_indent(v:count1, -1)<CR>
nnoremap <silent> gj :<C-u>call util#next_indent(v:count1, 1)<CR>
nnoremap Q @q
nnoremap Y y$

nnoremap <leader>q :quit<CR>
nnoremap <leader>u :update<CR>
nnoremap <leader>w <C-w>
nnoremap <leader>. :let @/=@"<cr>/<cr>cgn<c-r>.<esc>
nnoremap <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

inoremap <C-u> <C-g>u<C-u>

xnoremap . :normal .<CR>
xnoremap @ :<C-u>call util#repeat()<CR>

cnoremap <C-a> <Home>

vnoremap <silent> *
        \ :<C-U>
        \ let old_reg=getreg('"')<Bar>
        \ let old_regtype=getregtype('"')<CR>
        \ gvy/<C-R><C-R>=substitute(
        \ escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
        \ gV
        \ :call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> #
        \ :<C-U>
        \ let old_reg=getreg('"')<Bar>
        \ let old_regtype=getregtype('"')<CR>
        \ gvy?<C-R><C-R>=substitute(
        \ escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
        \ gV
        \ :call setreg('"', old_reg, old_regtype)<CR>

set pastetoggle=<C-_>
" }

" commands {
command! -nargs=1 Count execute printf('%%s/%s//gn', escape(<q-args>, '/'))
        \ | normal! ``
command! -bang -nargs=* -complete=file Make
        \ call make#make(<bang>0,<q-args>)
command! -nargs=? -complete=customlist,make#completion MakeStop
        \ call make#stop(<f-args>)
" }

" autocommands {
augroup guess
    autocmd!
    autocmd StdinReadPost,FilterReadPost,FileReadPost,BufReadPost
            \ * call start#guess()
augroup END

augroup lint
    autocmd!
    autocmd FileType asm
            \ let &l:makeprg='gcc -x assembler -fsyntax-only'
    autocmd FileType c
            \ let &l:makeprg='gcc -S -x c -fsyntax-only -Wall --std=c99'
    autocmd FileType cpp
            \ let &l:makeprg='g++ -S -x c++ -fsyntax-only -Wall --std=c++14'
    autocmd BufWritePost *.S,*.c,*.cpp silent :Make! <afile> | silent redraw!
    autocmd QuickFixCmdPost [^l]* cwindow
augroup END

augroup quickfix
    autocmd!
    autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
            \ q :cclose<CR>:lclose<CR>
    autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix') |
            \ bd | q | endif
    autocmd FileType qf set nobuflisted
augroup END

augroup git
    autocmd!
    autocmd BufNewFile,BufReadPost * call git#detect(expand('<amatch>:p:h'))
    autocmd BufEnter * call git#detect(expand('%:p:h'))
augroup END

augroup status
    autocmd!
    autocmd VimEnter,WinEnter,BufWinEnter * call status#refresh()
augroup END
" }

" text objects {
" cancel object {{
noremap <Plug>(EmptyObject) <nop>
inoremap <expr> <Plug>(EmptyObject) exists('#emptyobj')?"\<Esc>":''
" }}

" buffer object {{
xnoremap i% GoggV
onoremap i% :normal vi%<CR>
" }}

" fold object {{
xnoremap iz :<C-u>silent! normal! [zV]z<CR>
onoremap iz :normal viz<CR>
" }}

" indent object {{
xnoremap <silent> ii :<C-u>call textobj#indent('>=', 1, line("'<"), line("'>"), 0, 0)<CR>
onoremap <silent> ii :<C-u>call textobj#indent('>=', 1, line('.'), line('.'), 0, 0)<CR>
xnoremap <silent> ai :<C-u>call textobj#indent('>=', 1, line("'<"), line("'>"), -1, 1)<CR>
onoremap <silent> ai :<C-u>call textobj#indent('>=', 1, line('.'), line('.'), -1, 1)<CR>
xnoremap <silent> iI :<C-u>call textobj#indent('==', 0, line("'<"), line("'>"), 0, 0)<CR>
onoremap <silent> iI :<C-u>call textobj#indent('==', 0, line('.'), line('.'), 0, 0)<CR>
" }}

" comment object {{
xmap <silent> ic :<C-u>call textobj#comment(1)<CR><Plug>(EmptyObject)
omap <silent> ic :<C-u>call textobj#comment(0)<CR><Plug>(EmptyObject)
" }}

" line object {{
xnoremap il g_o^
onoremap il :normal vil<CR>
xnoremap al $o0
onoremap al :normal val<CR>
" }}

" path object {{
xnoremap <silent> if
        \ :<C-u>
        \ let epos = searchpos('\(\/\([0-9a-zA-Z_\-\.]\+\)\)\+', 'ceW', line('.')) <Bar>
        \ if epos == [0, 0] <Bar>
        \ let epos = searchpos('\(\/\([0-9a-zA-Z_\-\.]\+\)\)\+', 'bceW', line('.')) <Bar>
        \ endif <Bar>
        \ let spos = searchpos('\f\+', 'bcW', line('.')) <Bar>
        \ call textobj#select(spos, epos)<CR>
onoremap <silent> if :normal vif<CR>
" }}

" search pattern object {{
xnoremap <silent> i/
        \ :<C-u>
        \ let spos = searchpos(@\, 'c') <Bar>
        \ let epos = searchpos(@\, 'ce') <Bar>
        \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i/ :normal vi/<CR>
xnoremap <silent> i?
        \ :<C-u>
        \ let spos = searchpos(@\, 'bc') <Bar>
        \ let epos = searchpos(@\, 'ce') <Bar>
        \ :call textobj#select(spos, epos)<CR>
onoremap <silent> i? :normal vi?<CR>
" }}
" }

" highlight groups {
highlight! User1 ctermfg=7 ctermbg=6 cterm=bold
highlight! User2 ctermfg=7 ctermbg=3 cterm=bold
highlight! User3 ctermfg=7 ctermbg=1 cterm=bold
highlight! User4 ctermfg=7 ctermbg=2 cterm=bold
highlight! User5 ctermfg=7 ctermbg=5 cterm=bold
highlight! User6 ctermfg=7 ctermbg=8
highlight! User7 ctermfg=7 ctermbg=9
" }

" plugin settings {
" easyalign {{
xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)
" }}

" magit {{
let g:magit_show_magit_mapping = '<leader>m'
let g:magit_stage_hunk_mapping = 's'
let g:magit_commit_mapping = 'cm'
let g:magit_commit_amend_mapping = 'ca'
let g:magit_commit_fixup_mapping = 'cf'
let g:magit_close_commit_mapping = 'cq'
let g:magit_ignore_mapping = "<Nop>"
let g:magit_jump_next_hunk = 'n'
let g:magit_jump_prev_hunk = 'N'

let g:magit_git_cmd = 'git'
" }}

" peekaboo {{
let g:peekaboo_window = 'vert bo 40new'
" }}
" }

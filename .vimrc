execute pathogen#infect()

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

set pastetoggle=<C-_>
" }

" commands {
command! -nargs=1 Count execute printf('%%s/%s//gn', escape(<q-args>, '/'))
        \ | normal! ``
" }

" autocommands {
augroup guess
    autocmd!
    autocmd StdinReadPost,FilterReadPost,FileReadPost,BufReadPost
            \ * call start#guess()
augroup END

augroup quickfix
    autocmd!
    autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
            \ q :cclose<CR>:lclose<CR>
    autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix') |
            \ bd | q | endif
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

" highlight groups {
highlight! User1 ctermfg=7 ctermbg=6 cterm=bold
highlight! User2 ctermfg=7 ctermbg=3 cterm=bold
highlight! User3 ctermfg=7 ctermbg=1 cterm=bold
highlight! User4 ctermfg=7 ctermbg=2 cterm=bold
highlight! User5 ctermfg=7 ctermbg=5 cterm=bold
highlight! User6 ctermfg=7 ctermbg=8
highlight! User7 ctermfg=7 ctermbg=9
" }

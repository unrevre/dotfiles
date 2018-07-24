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

nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap ]l :lnext<CR>
nnoremap [l :lprev<CR>
nnoremap ]t :tabn<CR>
nnoremap [t :tabp<CR>

nnoremap Q @q
nnoremap Y y$

nnoremap <leader>q :quit<CR>
nnoremap <leader>u :update<CR>
nnoremap <leader>w <C-w>
nnoremap <leader>. :let @/=@"<cr>/<cr>cgn<c-r>.<esc>
nnoremap <leader>/ :execute 'vimgrep /'.@/.'/g %'<CR>:copen<CR>

inoremap <C-u> <C-g>u<C-u>

xnoremap . :normal .<CR>

cnoremap <C-a> <Home>

set pastetoggle=<C-_>
" }

" commands {
command! -nargs=1 Count execute printf('%%s/%s//gn', escape(<q-args>, '/'))
        \ | normal! ``
" }

" autocommands {
augroup quickfix
    autocmd!
    autocmd BufWinEnter quickfix nnoremap <silent> <buffer>
            \ q :cclose<CR>:lclose<CR>
    autocmd BufEnter * if (winnr('$') == 1 && &buftype ==# 'quickfix') |
            \ bd | q | endif
augroup END
" }

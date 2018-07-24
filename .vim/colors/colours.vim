" vi:syntax=vim

" Terminal color definitions
let s:cterm00 = "07"
let s:cterm01 = "15"
let s:cterm02 = "14"
let s:cterm03 = "13"
let s:cterm04 = "12"
let s:cterm05 = "09"
let s:cterm06 = "08"
let s:cterm07 = "00"
let s:cterm08 = "01"
let s:cterm09 = "11"
let s:cterm0A = "03"
let s:cterm0B = "02"
let s:cterm0C = "06"
let s:cterm0D = "04"
let s:cterm0E = "05"
let s:cterm0F = "10"

" Theme setup
hi clear
syntax reset
let g:colors_name = "colours"

" Highlighting function
fun <sid>hi(group, ctermfg, ctermbg, attr)
  if a:ctermfg != ""
    exec "hi " . a:group . " ctermfg=" . a:ctermfg
  endif
  if a:ctermbg != ""
    exec "hi " . a:group . " ctermbg=" . a:ctermbg
  endif
  if a:attr != ""
    exec "hi " . a:group . " cterm=" . a:attr
  endif
endfun

" Vim editor colors
call <sid>hi("Search", s:cterm03, s:cterm0A, "")
call <sid>hi("Visual", "",        s:cterm05, "")

" Remove functions
delf <sid>hi

" Remove color variables
unlet s:cterm00 s:cterm01 s:cterm02 s:cterm03
unlet s:cterm04 s:cterm05 s:cterm06 s:cterm07
unlet s:cterm08 s:cterm09 s:cterm0A s:cterm0B
unlet s:cterm0C s:cterm0D s:cterm0E s:cterm0F

" Title:        Morse Plugin
" Description:  A plugin to convert letter to morse code
" Last Change:  2023/04/25
" Maintainer:   Jerry Wang <jerrywang1981@outlook.com>
"
" https://en.wikipedia.org/wiki/Morse_code

if exists("g:loaded_morse") || &cp
  finish
endif


let s:save_cpo = &cpo
set cpo&vim

command! -nargs=0 MorseBuffer call morse#MorseBuffer()
nnoremap <Plug>MorseBuffer :call morse#MorseBuffer()<CR>

command! -nargs=0 MorseLine call morse#MorseLine()
nnoremap <Plug>MorseLine :call morse#MorseLine()<CR>


let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_morse = 1


let s:defaultMorseDict = {
      \ "dot": ".",
      \ "dash": "-",
      \ }

let s:space_3 = " "
let s:space_7 = "   "

let s:defaultLetterDict = {
      \ "a": ["dot", "dash"],
			\ "b": ["dash", "dot", "dot", "dot"],
		  \ "c": ["dash", "dot", "dash", "dot"],
      \ "d": ["dash", "dot", "dot"],
      \ "e": ["dot"],
      \ "f": ["dot", "dot", "dash", "dot"],
      \ "g": ["dash", "dash", "dot"],
      \ "h": ["dot", "dot", "dot", "dot"],
      \ "i": ["dot", "dot"],
      \ "j": ["dot", "dash", "dash", "dash"],
      \ "k": ["dash", "dot", "dash"],
      \ "l": ["dot", "dash", "dot", "dot"],
      \ "m": ["dash", "dash"],
      \ "n": ["dash", "dot"],
      \ "o": ["dash", "dash", "dash"],
      \ "p": ["dot", "dash", "dash", "dot"],
      \ "q": ["dash", "dash", "dot", "dash"],
      \ "r": ["dot", "dash", "dot"],
      \ "s": ["dot", "dot", "dot"],
      \ "t": ["dash"],
      \ "u": ["dot", "dot", "dash"],
      \ "v": ["dot", "dot", "dot", "dash"],
      \ "w": ["dot", "dash", "dash"],
      \ "x": ["dash", "dot", "dot", "dash"],
      \ "y": ["dash", "dot", "dash", "dash"],
      \ "z": ["dash", "dash", "dot", "dot"],
      \ "0": ["dash", "dash", "dash", "dash", "dash"],
      \ "1": ["dot", "dash", "dash", "dash", "dash"],
      \ "2": ["dot", "dot", "dash", "dash", "dash"],
      \ "3": ["dot", "dot", "dot", "dash", "dash"],
      \ "4": ["dot", "dot", "dot", "dot", "dash"],
      \ "5": ["dot", "dot", "dot", "dot", "dot"],
      \ "6": ["dash", "dot", "dot", "dot", "dot"],
      \ "7": ["dash", "dash", "dot", "dot", "dot"],
      \ "8": ["dash", "dash", "dash", "dot", "dot"],
      \ "9": ["dash", "dash", "dash", "dash", "dot"],
      \ ".": ["dot", "dash", "dot", "dash", "dot", "dash"],
      \ ",": ["dash", "dash", "dot", "dot", "dash", "dash"],
      \ "?": ["dot", "dot", "dash", "dash", "dot", "dot"],
      \ "'": ["dot", "dash", "dash", "dash", "dash", "dot"],
      \ "!": ["dash", "dot", "dash", "dot", "dash", "dash"],
      \ "/": ["dash", "dot", "dot", "dash", "dot"],
      \ "(": ["dash", "dot", "dash", "dash", "dot"],
      \ ")": ["dash", "dot", "dash", "dash", "dot", "dash"],
      \ ":": ["dash", "dash", "dash", "dot", "dot", "dot"],
      \ ";": ["dash", "dot", "dash", "dot", "dash", "dot"],
      \ "=": ["dash", "dot", "dot", "dot", "dash"],
      \ "+": ["dot", "dash", "dot", "dash", "dot"],
      \ "-": ["dash", "dot", "dot", "dot", "dot", "dash"],
      \ '"': ["dot", "dash", "dot", "dot", "dash", "dot"],
      \ "@": ["dot", "dash", "dash", "dot", "dash", "dot"],
      \ }


let s:bufferNamePrefix = "Morse"

function! s:getFinalMorseDict()
  if exists("g:morse_dict")
    return extend(extend({}, s:defaultMorseDict), g:morse_dict, "force")
  else
    return extend({}, s:defaultMorseDict)
  endif
endfunction

function! s:letter2MorseCode(letter)
  if empty(a:letter)
    return a:letter
  endif

  if strlen(a:letter) != 1
    echoerr "parameter must be one letter"
  endif
  if a:letter == " "
    return s:space_7
  endif

  let l:letter = tolower(a:letter)
  if has_key(s:defaultLetterDict, l:letter) == 0
    return a:letter
  endif

  let l:map = s:getFinalMorseDict()
  let l:code = get(s:defaultLetterDict, l:letter)
  return join(map(copy(l:code), 'l:map[v:val]'), "")
endfunction

function! s:word2MorseCode(word)
  let l:word = trim(a:word)
  return join(map(map(range(strlen(l:word)), 'l:word[v:val : v:val]'), 's:letter2MorseCode(v:val)'), s:space_3)
endfunction

function! s:paragraph2MorseCode(para)
  let l:para = split(a:para)
  return join(map(l:para, 's:word2MorseCode(v:val)'), s:space_7)
endfunction

function! s:text2MorseCode(text)
  let l:text = split(a:text, "\n")
  return join(map(l:text, 's:paragraph2MorseCode(v:val)'), "\n")
endfunction

function! s:getMorseBuffer(buf_num)
  " get morse buffer
  let l:morse_buf = bufnr(s:bufferNamePrefix . a:buf_num)
  if l:morse_buf != -1
    exe "bdelete " . l:morse_buf
  endif

  let l:morse_buf = bufnr(s:bufferNamePrefix . a:buf_num, 1)
  call setbufvar(l:morse_buf, "&buftype", "nofile")
  call setbufvar(l:morse_buf, "&bufhidden", "wipe")
  return l:morse_buf
endfunction

function! s:showMorseBufferWindow(morse_buf_num)
  let l:win_nr = bufwinnr(a:morse_buf_num)
  if l:win_nr == -1
    exe "vsplit +buffer" . a:morse_buf_num
    let l:win_nr = bufwinnr(a:morse_buf_num)
  endif
  return l:win_nr
endfunction

function! morse#MorseBuffer()
  let l:lines = getline(1, line("$"))
  " if prefer to save the result to register
  let l:save_to_reg = exists("g:morse_save_to_reg") ? g:morse_save_to_reg : 0
  if l:save_to_reg != 0
    call setreg(v:register, map(l:lines, 's:paragraph2MorseCode(v:val)'))
    return
  endif
  " get current buffer number
  let l:buf = bufnr("")
  " create morse code buffer
  let l:morse_buf = s:getMorseBuffer(l:buf)
  call s:showMorseBufferWindow(l:morse_buf)
  call setline(1, map(l:lines, 's:paragraph2MorseCode(v:val)'))
endfunction

function! morse#MorseLine()
  let l:line = getline(".")
  " if prefer to save the result to register
  let l:save_to_reg = exists("g:morse_save_to_reg") ? g:morse_save_to_reg : 0
  if l:save_to_reg != 0
    call setreg(v:register,s:paragraph2MorseCode(l:line))
    return
  endif
  " get current buffer number
  let l:buf = bufnr("")
  " create morse code buffer
  let l:morse_buf = s:getMorseBuffer(l:buf)
  call s:showMorseBufferWindow(l:morse_buf)
  call setline(1, s:paragraph2MorseCode(l:line))
endfunction

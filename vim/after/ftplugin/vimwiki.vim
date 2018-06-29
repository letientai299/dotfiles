fun! PrepareDateHheader()
  let view=winsaveview()

  " Insert date tag: like 2018-06-29 Friday
  call append(0, '= '.strftime("%Y-%m-%d %A").' =')
  " Append a new line
  call append(1, '')

  let view.lnum += 2
  call winrestview(view)
endfun!
nmap <buffer> <Leader>dd :call PrepareDateHheader()<CR>

" This one will insert the current time as H2
nmap <buffer> <Leader>dt Godtt <BS><ESC>==<<o

" Delete link syntax arround the current token
nmap <buffer> <Leader><CR> ds]ds]

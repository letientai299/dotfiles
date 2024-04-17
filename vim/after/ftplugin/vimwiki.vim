fun! PrepareDateHheader()
  let view=winsaveview()

  " Insert date tag: like 2018-06-29 Friday
  call append(0, '= '.strftime("%Y-%m-%d %A").' =')

  let view.lnum += 1
  call winrestview(view)
endfun!


fun! PrepareTimeHheader()
  let view=winsaveview()

  call append(view.lnum, '== '.strftime("%T").' ==')

  let view.lnum += 1
  call winrestview(view)
endfun!

iunmap <buffer> <Tab>
nmap <buffer> <Leader>dd :call PrepareDateHheader()<CR>

" This one will insert the current time as H2
nmap <buffer> <Leader>dt :call PrepareTimeHheader()<CR>

" Delete link syntax arround the current token
nmap <buffer> <Leader><CR> ds]ds]
nmap <buffer> <leader>a yyp4WbhWDA

setlocal spell

nnoremap <leader>o yyp>>S-<space>

fun! PrepareDateHheader()
  let view=winsaveview()

  " Insert date tag: like 2018-06-29 Friday
  call append(0, '= '.strftime("%Y-%m-%d %A").' =')

  let view.lnum += 2
  call winrestview(view)
endfun!
nmap <buffer> <Leader>dd :call PrepareDateHheader()<CR>

" This one will insert the current time as H2
nmap <buffer> <Leader>dt Go<CR>dtt <BS><ESC>==<<o

" Delete link syntax arround the current token
nmap <buffer> <Leader><CR> ds]ds]

setlocal spell

nnoremap <leader>o yyp>>S-<space>
nmap <leader>t<leader>t :VimwikiMakeTomorrowDiaryNote<ESC>

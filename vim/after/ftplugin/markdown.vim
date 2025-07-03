set sts=2 ts=2 sw=2

nnoremap <buffer> Q a```<cr>```<ESC>O

nnoremap <buffer> <c-space> :silent! .s/^\(\s*\)- \[\([x ]\)\]/\=submatch(2)==' '
  \? submatch(1) . '- [x]'
  \: submatch(1) . '- [ ]'
  \<cr>:silent! noh<cr>

let g:neoformat_enabled_markdown = ['prettierd', 'prettier', 'denofmt', 'mdformat', 'remark']

" if the markdown file path is under "$NOTE/diary" folder, 
" then add map <leader>dt to call NoteNow()
if expand('%:p') =~# $NOTE . '/diary/'
  function! g:NoteNow() 
    " Append a h2 header with the current time to the end of the current file, 
    call append(line("$"), '## ' . strftime('%H:%M') )
    call append(line("$"), '')
    normal G
    startinsert
  endfunction

  nnoremap <buffer> <leader>dt :call g:NoteNow()<cr>
endif
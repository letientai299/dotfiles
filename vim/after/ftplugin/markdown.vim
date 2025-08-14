set sts=2 ts=2 sw=2

nnoremap <buffer> Q a```<cr>```<ESC>O

" Function to toggle or convert markdown list item to checklist
function! ToggleMarkdownChecklist()
  let line = getline('.')
  if line =~# '^\s*- \[x\]'
    execute 's/^\(\s*\)- \[x\]/\1- [ ]/'
  elseif line =~# '^\s*- \[ \]'
    execute 's/^\(\s*\)- \[ \]/\1- [x]/'
  elseif line =~# '^\s*- '
    execute 's/^\(\s*\)- \(.*\)$/\1- [ ] \2/'
  endif
  silent! noh
endfunction

nnoremap <buffer> <c-space> :call ToggleMarkdownChecklist()<cr>

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

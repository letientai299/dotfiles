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


" Pressing Enter: open markdown link via gx, or open/create file if on filepath
function! s:OpenLinkOrFile()
  let line = getline('.')
  let col = col('.')

  " Try to match markdown link at cursor
  let link_pattern = '\v\[(.{-})\]\((.{-})\)'
  let match = matchstrpos(line, link_pattern)
  if match[1] >= 0 && col >= match[1]+1 && col <= match[1]+len(match[2])
    echom 'OpenLinkOrFile: Detected markdown link, using gx.'
    normal! gx
    return
  endif

  " Try to match raw http(s):// link at cursor
  let url_pattern = '\vhttps?://[^\s)]+'
  let url_match = matchstrpos(line, url_pattern)
  if url_match[1] >= 0 && col >= url_match[1]+1 && col <= url_match[1]+len(url_match[2])
    echom 'OpenLinkOrFile: Detected raw URL, using gx.'
    normal! gx
    return
  endif

  " Try to match filepath at cursor (cross-platform)
  let file_pattern = '\v((\~|\.|/|\\)|([A-Za-z]:\\))?[\w\-\.\\/]+\.[\w]+'
  let file_match = matchstrpos(line, file_pattern)
  if file_match[1] >= 0 && col >= file_match[1]+1 && col <= file_match[1]+len(file_match[2])
    let filepath = matchstr(line, file_pattern)
    " Convert backslashes to slashes for Vim
    let filepath = substitute(filepath, '\\', '/', 'g')
    " Expand ~, relative, and drive letter paths
    let abs_path = fnamemodify(filepath, ':p')
    " Create parent dirs if needed
    call mkdir(fnamemodify(abs_path, ':h'), 'p')
    " Create file if it doesn't exist
    if !filereadable(abs_path)
      call writefile([], abs_path)
    endif
    " Open file in a new buffer
    execute 'edit ' . abs_path
    return
  endif

  " Fallback: normal Enter
  normal! \<CR>
endfunction

nnoremap <buffer> <CR> :call <SID>OpenLinkOrFile()<CR>

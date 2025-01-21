set sts=2 ts=2 sw=2

nnoremap <buffer> Q a```<cr>```<ESC>O

nnoremap <buffer> <c-space> :silent! .s/^\(\s*\)- \[\([x ]\)\]/\=submatch(2)==' '
  \? submatch(1) . '- [x]'
  \: submatch(1) . '- [ ]'
  \<cr>:silent! noh<cr>

let g:neoformat_enabled_markdown = ['prettierd', 'prettier', 'denofmt', 'mdformat', 'remark']


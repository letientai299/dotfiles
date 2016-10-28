let g:tsuquyomi_completion_detail = 1
let g:tsuquyomi_disable_quickfix = 1
let g:syntastic_typescript_checkers = ['tsuquyomi'] " You shouldn't use 'tsc' checker.

function SetupTypescriptWithTsuquyomi()
  " Setting
  setlocal completeopt+=menu,preview
  nmap <buffer> <Leader>ti :TsuImport<CR>
  nmap <buffer> <Leader>th :<C-u>echo tsuquyomi#hint()<CR>
  nmap <buffer> <Leader>te <Plug>(TsuquyomiRenameSymbol)
endfu



autocmd FileType typescript call SetupTypescriptWithTsuquyomi()

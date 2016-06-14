nmap <buffer> <leader>b <Plug>(go-build)
nmap <buffer> <leader>t <Plug>(go-test)
nmap <buffer> <leader>c <Plug>(go-coverage)
nmap <buffer> <Leader>ds <Plug>(go-def-split)
nmap <buffer> <Leader>dv <Plug>(go-def-vertical)
nmap <buffer> <Leader>dt <Plug>(go-def-tab)
nmap <buffer> <Leader>gd <Plug>(go-doc)
nmap <buffer> <Leader>gv <Plug>(go-doc-vertical)
nmap <buffer> <Leader>gb <Plug>(go-doc-browser)
nmap <buffer> <Leader>s <Plug>(go-implements)
nmap <buffer> <Leader>i <Plug>(go-info)
nmap <buffer> <Leader>e <Plug>(go-rename)
"
" ----------------------
" Using with Neovim (beta)
nmap <buffer> <Leader>r  <Plug>(go-run-vertical)

" By default new terminals are opened in a vertical split. To change it
let g:go_term_mode = "split"
" ----------------------


" By default syntax-highlighting for Functions, Methods and Structs is disabled. To change it:
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_fields = 1
let g:go_highlight_structs = 1
let g:go_highlight_interfaces = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1


" Enable goimports to automatically insert import paths instead of gofmt:
let g:go_fmt_command = "goimports"

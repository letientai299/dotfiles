let NERDSpaceDelims=1

nnoremap <C-\> :Neotree toggle reveal_force_cwd<CR>
nnoremap <A-\> :Neotree reveal toggle reveal_force_cwd<CR>

nnoremap <c-g> :silent Vista finder<CR>
nnoremap <c-f11> :silent Vista!!<CR>
nnoremap <f35> :silent Vista!!<CR>

" Resolve project root from a symbol link.
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1
let g:rooter_manual_only = 1
let g:rooter_change_directory_for_non_project_files = ''

" formatter
let g:formatters_yaml=['prettier']
let g:formatters_typescriptreact=['prettier']
let g:formatters_javascriptreact=['prettier']
let g:formatters_javascript=['prettier']
let g:formatters_typescript=['prettier']
let g:formatters_json=['prettier']
let g:formatters_html=['prettier']
let g:formatters_css=['prettier']
let g:formatters_lua=['stylua']
let g:formatters_go=['gofumpt']

" See also https://github.com/darold/pgFormatter
" let g:formatdef_sql_formatter='pg_format --inplace'
let g:formatdef_pg_formatter=['pg_format --inplace']
let g:formatters_sql=['pg_format']


augroup MarkdownColors
  autocmd!
  autocmd ColorScheme * hi! link mkdCodeDelimiter markdownCode
  autocmd ColorScheme * hi! link VirtColumn Label
augroup END

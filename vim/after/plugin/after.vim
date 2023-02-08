let NERDSpaceDelims=1

nnoremap <C-\> :Neotree toggle<CR>
nnoremap <A-\> :Neotree reveal toggle<CR>

nnoremap <c-g> :Vista finder<CR>
nnoremap <c-f11> :Vista!!<CR>
nnoremap <f35> :Vista!!<CR>

" Resolve project root from a symbol link.
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1
let g:rooter_manual_only = 1
let g:rooter_change_directory_for_non_project_files = ''

" formatter
let g:formatters_yaml=['prettier']
let g:formatters_html=['prettier']
let g:formatters_lua=['stylua']

" See also https://github.com/darold/pgFormatter
let g:formatdef_sql_formatter='"sql-formatter"'
let g:formatters_sql=['sql_formatter']

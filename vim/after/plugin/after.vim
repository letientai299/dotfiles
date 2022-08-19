let NERDSpaceDelims=1

nnoremap <C-\> :Neotree toggle<CR>
nnoremap <A-\> :Neotree reveal toggle<CR>

" Resolve project root from a symbol link.
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1
let g:rooter_manual_only = 1
let g:rooter_change_directory_for_non_project_files = ''

let g:tagbar_type_vimwiki = {
                  \   'ctagstype':'vimwiki'
                  \ , 'kinds':['h:header']
                  \ , 'sro':'&&&'
                  \ , 'kind2scope':{'h':'header'}
                  \ , 'sort':0
                  \ , 'ctagsbin':'~/.vim/after/plugin/vwtags.py'
                  \ , 'ctagsargs': 'default'
                  \ }

" Add support for markdown files in tagbar.
let g:tagbar_type_markdown = {
                  \ 'ctagstype': 'markdown',
                  \ 'ctagsbin' : '~/.vim/after/plugin/markdown2ctags.py',
                  \ 'ctagsargs' : '-f - --sort=yes',
                  \ 'kinds' : [
                  \ 's:sections',
                  \ 'i:images'
                  \ ],
                  \ 'sro' : '|',
                  \ 'kind2scope' : {
                  \ 's' : 'section',
                  \ },
                  \ 'sort': 0,
                  \ }

" formatter
let g:formatters_yaml=['prettier']
let g:formatters_html=['prettier']
let g:formatters_lua=['stylua']
" https://github.com/darold/pgFormatter
let g:formatdef_pg_format='"pg_format"'
let g:formatters_sql=['pg_format']

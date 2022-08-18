" ALE {{{ "
let g:ale_sign_column_always = 1
" }}} "

" Allow netrw to remove non-empty local dirs
let g:netrw_localrmdir='rm'
let g:netrw_localrmdiropt='-rf'

let NERDSpaceDelims=1

nnoremap <C-\> :NvimTreeToggle<CR>
nnoremap <A-\> :NvimTreeFindFile<CR>

" rooter {{{ "
" Resolve project root from a symbol link.
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1
let g:rooter_manual_only = 1
let g:rooter_change_directory_for_non_project_files = ''
" }}} "

" tagbar {{{ "
" Map <C-F1> to view tagbar
nmap <C-F11> :TagbarToggle<CR>
nmap <F35> :TagbarToggle<CR>
let g:tagbar_autoclose=0
let g:tagbar_autofocus=1


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
" }}} tagbar "

" startify {{{ "
" Disable random header
" let g:startify_custom_header = []

" Make vim-session and startify use the same dir
let g:startify_session_dir='~/.vim/sessions'

let g:startify_list_order = [
                  \ ['Recently used files:'],
                  \ 'files',
                  \ ['Sessions:'],
                  \ 'sessions',
                  \ ['Recently used files in the current directory:'],
                  \ 'dir',
                  \ ['Bookmarks:'],
                  \ 'bookmarks',
                  \ ]

let g:startify_session_persistence = 1
let g:startify_files_number = 20
let g:startify_session_autoload = 1
let g:startify_update_oldfiles = 1
" }}} startify "

" Ultisnips {{{ "
" Trigger configuration.
" let g:UltiSnipsExpandTrigger="<tab>"
" let g:UltiSnipsJumpForwardTrigger="<c-j>"
" let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" let g:UltiSnipsSnippetDirectories=["UltiSnips"]
" au! BufEnter *.jsx UltiSnipsAddFiletypes javascript-es6-react
" }}} Ultisnips "

let g:asyncrun_open = 8
fun! TranslateCurrentWord()
      " Get the word under cursor for translation
      let word_under_cursor = expand("<cword>")
      " After translate, open the quickfix list and immediately back to previous
      " buffer
      " execute 'AsyncRun! -post='.post_command.' trans :vi -no-ansi --brief '.word_under_cursor
      execute 'AsyncRun! trans :vi -no-ansi '.word_under_cursor
endfun


" call deoplete#custom#option({
" \ 'min_pattern_length': 1,
" \ })

" let g:user_emmet_settings = {
" \  'javascript.jsx' : {
" \      'extends' : 'jsx',
" \  },
" \}


" Define yaml formatter
let g:formatters_yaml=['prettier']
let g:formatters_html=['prettier']

let g:formatters_lua=['stylua']

" https://github.com/darold/pgFormatter
let g:formatdef_pg_format='"pg_format"'
let g:formatters_sql=['pg_format']

" ALE {{{ "
let g:ale_sign_column_always = 1
" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
" }}} "

" Fzf {{{1 "
" Mapping selecting mappings
nmap <c-p> :Files<CR>

" Advanced customization using autoload functions
inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

" Augmenting Ag command using fzf#vim#with_preview function
"   * fzf#vim#with_preview([[options], preview window, [toggle keys...]])
"     * For syntax-highlighting, Ruby and any of the following tools are required:
"       - Highlight: http://www.andre-simon.de/doku/highlight/en/highlight.php
"       - CodeRay: http://coderay.rubychan.de/
"       - Rouge: https://github.com/jneen/rouge
"
"   :Ag  - Start fzf with hidden preview window that can be enabled with "?" key
"   :Ag! - Start fzf in fullscreen and display the preview window above
command! -bang -nargs=* Ag
  \ call fzf#vim#ag(<q-args>,
  \                 <bang>0 ? fzf#vim#with_preview('up:60%')
  \                         : fzf#vim#with_preview(),
  \                 <bang>0)

"" Files command with preview window
command! -bang -nargs=? -complete=dir Files
  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)

" 1}}} "

" NerdCommenter {{{1 "
let NERDSpaceDelims=1
" 1}}} "

" nerdtree {{{1 "
" nnoremap <F12> :NERDTreeToggle<CR>
" nnoremap <S-F12> :NERDTreeFind<CR>
" nnoremap <F24> :NERDTreeFind<CR>

" " For https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
" let g:NERDTreeFileExtensionHighlightFullName = 1
" let g:NERDTreeExactMatchHighlightFullName = 1
" let g:NERDTreePatternMatchHighlightFullName = 1
" 1}}} "

" rooter {{{ "
" Resolve project root from a symbol link.
let g:rooter_resolve_links = 1
let g:rooter_silent_chdir = 1
let g:rooter_change_directory_for_non_project_files = 'current'
" }}} "

" Vimwiki {{{ "
"Set up for vimwiki
let wiki = {}
let wiki.path = "$NOTE/"

let wiki.nested_syntaxes ={
            \'python': 'python',
            \'py':     'python',
            \'c++':    'cpp',
            \'c':      'c',
            \'scala':  'scala',
            \'java':   'java',
            \'js':   'javascript',
            \'gql':   'graphql',
            \'graphql':   'graphql'
            \}

let g:vimwiki_list = [wiki]
let g:vimwiki_hl_cb_checked = 1
" }}} Vimwiki "

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
let g:startify_custom_header = []

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
let g:startify_update_oldfiles = 1
" }}} startify "

" Ultisnips {{{ "
" Trigger configuration.
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]
" }}} Ultisnips "


" ALE {{{ "
let g:ale_sign_column_always = 1
" Set this. Airline will handle the rest.
let g:airline#extensions#ale#enabled = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
" }}} "

" Fzf {{{1 "
" Mapping selecting mappings
nmap <c-p> :OFiles<CR>
nmap <a-p> :Files<CR>
nmap <leader><c-p> :DFiles<CR>

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

command! -bang -nargs=* Rg
                  \ call fzf#vim#grep(
                  \ 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
                  \ <bang>0 ? fzf#vim#with_preview('up:60%')
                  \         : fzf#vim#with_preview(),
                  \ <bang>0)

command! -bang -nargs=? -complete=dir DFiles
                  " \ call fzf#vim#files(expand('%:p:h'), fzf#vim#with_preview(), <bang>0)

cnoreabbrev rg Rg

"" Files command with preview window
command! -bang -nargs=? -complete=dir Files
                  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)


"" Non ignored files
command! -bang -nargs=? -complete=dir OFiles
  \ call fzf#run(fzf#wrap({'source': '(git status --short --untracked-files | grep "^?" | cut -d\  -f2- && git ls-files) | sort -u'}))
" 1}}} "

" NerdCommenter {{{1 "
let NERDSpaceDelims=1
" 1}}} "

" nerdtree and ranger {{{1 "
nnoremap <C-\> :NERDTreeToggle<CR>
nnoremap <A-\> :NERDTreeFind<CR>

" " For https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
" let g:NERDTreeFileExtensionHighlightFullName = 1
" let g:NERDTreeExactMatchHighlightFullName = 1
" let g:NERDTreePatternMatchHighlightFullName = 1
augroup nerdtreedisablecursorline
      autocmd!
      autocmd FileType nerdtree setlocal nocursorline
augroup end

map <leader>rf :RangerCurrentFile<CR>
map <leader>rt :RangerCurrentFileNewTab<CR>
map <leader>rr :RangerWorkingDirectory<CR>
map <leader>rT :RangerWorkingDirectoryNewTab<CR>
" 1}}} "

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
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]
au! BufEnter *.jsx UltiSnipsAddFiletypes javascript-es6-react
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

" https://github.com/darold/pgFormatter
let g:formatdef_pg_format='"pg_format"'
let g:formatters_sql=['pg_format']

" Disable random header
let g:startify_custom_header = []

" Make vim-session and startify use the same dir
let g:startify_session_dir='~/.vim/sessions'

let g:startify_list_order = [
      \ ['   ✟  Recently used files:'],
      \ 'files',
      \ ['   ☕  Sessions:'],
      \ 'sessions',
      \ ['   ☣  Recently used files in the current directory:'],
      \ 'dir',
      \ ['   ⚓  Bookmarks:'],
      \ 'bookmarks',
      \ ]

let g:startify_session_persistence = 1
let g:startify_files_number = 20
let g:startify_update_oldfiles = 1

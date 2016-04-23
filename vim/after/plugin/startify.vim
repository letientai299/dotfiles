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

let g:startify_session_persistence = 0

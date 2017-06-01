" Map <C-F1> to view tagbar
nmap <C-F11> :TagbarToggle<CR>
let g:tagbar_autoclose=1
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


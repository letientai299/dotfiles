"Set up for vimwiki
let wiki = {}
let wiki.path = '$NOTE/vimwiki/'

let wiki.nested_syntaxes ={
            \'python': 'python',
            \'py':     'python',
            \'c++':    'cpp',
            \'c':      'c',
            \'scala':  'scala',
            \'java':   'java',
            \'js':   'javascript'
            \}

let g:vimwiki_list = [wiki]

let g:vimwiki_hl_cb_checked = 1

" Open new line after a checkbox-line without the checkbox.
nmap <Leader>wo o<C-W><C-w><C-w><ESC>>>A
nmap <Leader>wO O<C-W><C-w><C-w><ESC>>>A

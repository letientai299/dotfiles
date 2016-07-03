"Set up for vimwiki
let wiki = {}
let wiki.path = '$NOTE/vimwiki/'

let wiki.nested_syntaxes ={
            \'python': 'python',
            \'py':     'python',
            \'c++':    'cpp',
            \'c':      'c',
            \'scala':  'scala',
            \'java':   'java'
            \}

let g:vimwiki_list = [wiki]

let g:vimwiki_hl_cb_checked = 1

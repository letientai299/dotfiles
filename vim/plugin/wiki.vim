" Vimwiki {{{ "
"Set up for vimwiki
let wiki = {}
let wiki.path = "$NOTE/"

let wiki.nested_syntaxes ={
            \'python': 'python',
            \'py':     'python',
            \'sql':     'pgsql',
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

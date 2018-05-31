let vimwiki_html_path = $HOME.'/vimwiki_html/'
let wiki = {}
let wiki.path = $NOTE
let wiki.path_html = vimwiki_html_path
let wiki.template_path = vimwiki_html_path.'assets/'
let wiki.template_default = 'default'
let wiki.template_ext = ".html"
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

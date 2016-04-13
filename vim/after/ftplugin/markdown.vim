" Insert a code bloke in markdown
nnoremap <buffer> Q i```<CR><CR>```<ESC>ki

map <buffer> j gj
map <buffer> k gk

" Insert bold mark
imap <buffer> <C-b> ****<ESC>hi

call WordProcessorMode()

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1


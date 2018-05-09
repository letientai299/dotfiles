" Insert a code bloke in markdown
nnoremap <buffer> Q i```<CR><CR>```<ESC>ki

map <buffer> j gj
map <buffer> k gk

" Insert bold mark
imap <buffer> <C-b> ****<ESC>hi

let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_conceal = 3
let g:vim_markdown_new_list_item_indent = 2

set tw=80
" Auto hard line break using textwidth option.
set fo-=l
set fo+=t

" Insert a second level or first level header line below the current line in
" normal mode
nnoremap <buffer> <Leader>l yypVr-
nnoremap <buffer> <Leader>L yypVr=

" Change header level, this works well if the current line is already a header,
" and not work for the opposite.
nnoremap <buffer> = V:HeaderIncrease<CR><ESC><ESC>
nnoremap <buffer> + V:HeaderIncrease<CR><ESC><ESC>
nnoremap <buffer> - V:HeaderDecrease<CR><ESC><ESC>

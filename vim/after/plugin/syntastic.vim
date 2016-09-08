set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_wq = 0


let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": ["sh", "zsh", "py", "php", "js"],
    \ "passive_filetypes": ["json"] }

" Don't check .json files
" Don't known why but my setup give annoying error when I try to save json
" file.

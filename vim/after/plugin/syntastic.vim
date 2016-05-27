set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_wq = 0


let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": ["sh", "zsh", "py", "php", "js", "json"],
    \ "passive_filetypes": [] }

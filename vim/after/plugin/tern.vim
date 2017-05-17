let g:tern_request_timeout = 1
let g:tern_show_signature_in_pum = 1

let g:tern#command = ["tern"]
let g:tern#arguments = ["--persistent"]

autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
" autocmd FileType javascript setlocal omnifunc=tern#Complete
let g:tern_map_keys=1
let g:tern_show_argument_hints="on_hold"


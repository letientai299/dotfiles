" Insert a second level or first level header line below the current line in
" normal mode
"----------------------------------------------------------------------------
nnoremap <leader>l yypVr-
nnoremap <leader>L yypVr=

" Insert a code bloke in markdown
nnoremap Q i```<CR><CR>```<ESC>ki

" Change textwidth for adapt to markdown file type
set cc=



" Mapping to make movements operate on 1 screen line in wrap mode
function! ScreenMovement(movement)
    if &wrap && b:gmove == 'yes'
        return "g" . a:movement
    else
        return a:movement
    endif
endfunction

onoremap <silent> <expr> j ScreenMovement("j")
onoremap <silent> <expr> k ScreenMovement("k")
onoremap <silent> <expr> 0 ScreenMovement("0")
onoremap <silent> <expr> ^ ScreenMovement("^")
onoremap <silent> <expr> $ ScreenMovement("$")
nnoremap <silent> <expr> j ScreenMovement("j")
nnoremap <silent> <expr> k ScreenMovement("k")
nnoremap <silent> <expr> 0 ScreenMovement("0")
nnoremap <silent> <expr> ^ ScreenMovement("^")
nnoremap <silent> <expr> $ ScreenMovement("$")
vnoremap <silent> <expr> j ScreenMovement("j")
vnoremap <silent> <expr> k ScreenMovement("k")
vnoremap <silent> <expr> 0 ScreenMovement("0")
vnoremap <silent> <expr> ^ ScreenMovement("^")
vnoremap <silent> <expr> $ ScreenMovement("$")
vnoremap <silent> <expr> j ScreenMovement("j")

" toggle showbreak
function! TYShowBreak()
    if &showbreak == ''
        set showbreak=>
    else
        set showbreak=
    endif
endfunction
let b:gmove = "yes"
function! TYToggleBreakMove()
    if exists("b:gmove") && b:gmove == "yes"
        let b:gmove = "no"
    else
        let b:gmove = "yes"
    endif
endfunction
nmap  <expr> ,b TYShowBreak()
nmap  <expr> ,bb TYToggleBreakMove()


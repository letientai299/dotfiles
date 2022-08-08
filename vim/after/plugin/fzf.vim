" Mapping selecting mappings
nmap <leader>f :OFiles<CR>
nmap <leader>af :Files<CR>
nmap <leader>df :DFiles<CR>
nmap <leader>b :Buffers<CR>
nmap <leader>h :History<CR>
nmap <leader>gh :Commits<CR>
nmap <leader>bh :BCommits<CR>
nmap <leader><c-m> :Marks<CR>
nmap <leader>gf :GitFiles<CR>

" Advanced customization using autoload functions
" inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

command! -bang -nargs=* Rg
                  \ call fzf#vim#grep(
                  \ 'rg --column --line-number --no-heading --color=always --smart-case '.shellescape(<q-args>), 1,
                  \ <bang>0 ? fzf#vim#with_preview('up:60%')
                  \         : fzf#vim#with_preview(),
                  \ <bang>0)

command! -bang -nargs=? -complete=dir DFiles
                  \ call fzf#vim#files(expand('%:p:h'), fzf#vim#with_preview(), <bang>0)

cnoreabbrev rg Rg

"" Files command with preview window
command! -bang -nargs=? -complete=dir Files
                  \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)


"" Non ignored files
command! -bang -nargs=? -complete=dir OFiles
  \ call fzf#run(fzf#wrap({'source': '(git status --short --untracked-files | grep "^?" | cut -d\  -f2- && git ls-files) | sort -u'}))

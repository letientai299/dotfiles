nmap <leader>fa :FzfLua<CR>

nmap <leader>fb :FzfLua buffers<CR>

nmap <leader>fc :FzfLua git_bcommits<CR>
nmap <leader>fC :FzfLua git_commits<CR>

nmap <leader>ff :FzfLua files<CR>
nmap <leader>fF :FzfLua gitFiles<CR>

nmap <leader>fm :FzfLua keymaps<CR>

nmap <leader>fg :FzfLua live_grep_native<CR>

nmap <leader>fh :FzfLua oldfiles<CR>
nmap <leader>f' :FzfLua marks<CR>

lua require('fzf-lua').register_ui_select()

  function! s:project_mru_files() abort
    let old=map(
    \ filter(extend([expand('#:p')], copy(v:oldfiles)),
    \   'v:val =~ getcwd() . "/"'
    \  . ' && filereadable(v:val)'
    \  . ' && v:val !~# ".*/\.git/index$"'
    \  . ' && v:val !~# ".*/\.git/COMMIT_EDITMSG$"'
    \ ),
    \ 'fnamemodify(v:val, ":.")'
    \ )
    let fd = split(system('fd --type f --hidden -E ".git"'))
    return fzf#vim#_uniq(old + fd)
  endfunction

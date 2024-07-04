nmap <leader>fa :FzfLua<CR>

nmap <leader>fb :FzfLua buffers<CR>

nmap <leader>fc :FzfLua git_bcommits<CR>
nmap <leader>fC :FzfLua git_commits<CR>

nmap <leader>ff :FzfLua files<CR>
nmap <leader>fF :FzfLua git_files<CR>

nmap <leader>fm :FzfLua keymaps<CR>
nmap <leader>fx :FzfLua commands<CR>

nmap <leader>fg :FzfLua live_grep_native<CR>

nmap <leader>fh :FzfLua oldfiles<CR>
nmap <leader>f' :FzfLua marks<CR>

lua require('fzf-lua').register_ui_select()


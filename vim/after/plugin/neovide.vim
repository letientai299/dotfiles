"-------------------------------------------------------------------------------
" Neovide config
"-------------------------------------------------------------------------------
"
if exists("g:neovide")
  Neotree toggle show position=left reveal_force_cwd
  lua require('neovide')
end

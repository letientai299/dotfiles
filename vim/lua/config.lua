require("bufferline").setup({})
require("lualine").setup({})

require("toggleterm").setup({
  insert_mappings = true,
  open_mapping = [[<c-t>]],
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
vim.keymap.set('n', '<c-F12>', [[ToggleTerm size=40 direction=horizontal]])

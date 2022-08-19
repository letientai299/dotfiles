local nightfox = require("nightfox")
nightfox.compile()

vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha
require("catppuccin").setup({
  dim_inactive = {
    enabled = true,
    shade = "dark",
    percentage = 0.3,
  },

  compile = {
    enabled = true,
  },

  integration = {
    dap = {
      enabled = true,
    },
    which_key = true,
  },
})
vim.cmd([[CatppuccinCompile]])
vim.cmd([[colorscheme catppuccin]])

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])
require("neo-tree").setup({
  popup_border_style = "rounded", -- "double", "none", "rounded", "shadow", "single" or "solid"
})

require("bufferline").setup({})
require("lualine").setup({ theme = "catppuccin" })

require("toggleterm").setup({
  insert_mappings = true,
  open_mapping = [[<c-t>]],
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

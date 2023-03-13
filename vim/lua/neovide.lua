-- use option as alt key
vim.g.neovide_input_macos_alt_is_meta = true

-- change dir if we start at root, to limit the file searching.
if vim.fn.getcwd() == '/' then
  vim.fn.chdir("$HOME/temp/")
end

-- use a dashboard for nicer startup
require('alpha').setup(require 'alpha.themes.startify'.config)
vim.g.neovide_input_use_logo = 1            -- enable use of the logo (cmd) key
vim.keymap.set('v', '<D-c>', '"+y')         -- Copy
vim.keymap.set('n', '<D-v>', '"+P')         -- Paste normal mode
vim.keymap.set('v', '<D-v>', '"+P')         -- Paste visual mode
vim.keymap.set('c', '<D-v>', '<C-R>+')      -- Paste command mode
vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode

-- Allow clipboard copy paste in neovim
vim.g.neovide_input_use_logo = 1
vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })

-- font
vim.o.guifont = "JetBrainsMono_Nerd_Font:h15"

-- cursors
vim.g.neovide_cursor_vfx_mode = "torpedo"

-- dynamic scalling at runtime
vim.g.neovide_scale_factor = 1.0

local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

vim.keymap.set("n", "<C-=>", function()
  change_scale_factor(1.25)
end)

vim.keymap.set("n", "<C-->", function()
  change_scale_factor(1 / 1.25)
end)

vim.o.winblend = 30
vim.o.pumblend = 30

-- auto change dir when using GUI mode
vim.g.rooter_manual_only = 0

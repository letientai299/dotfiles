vim.g.neovide_refresh_rate = 60
vim.g.neovide_cursor_animation_length = 0.1
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_hide_mouse_when_typing = true

-- use option as alt key
vim.g.neovide_input_macos_alt_is_meta = true

-- change dir if we start at root, to limit the file searching.
if vim.fn.getcwd() == '/' then
  vim.fn.chdir("$HOME")
end


-- Allow clipboard copy paste in neovim
vim.g.neovide_input_use_logo = 1
vim.api.nvim_set_keymap('', '<D-c>', '"+y', { noremap = true, silent = true }) -- Copy
vim.api.nvim_set_keymap('', '<D-v>', '+p<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('!', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('t', '<D-v>', '<C-R>+', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<D-v>', '<C-R>+', { noremap = true, silent = true })

-- font
vim.o.guifont = "JetBrainsMono Nerd Font Mono:style=Light,Regular:h15"

-- cursors
vim.g.neovide_cursor_vfx_mode = "torpedo"

-- dynamic scalling at runtime
vim.g.neovide_scale_factor = 1

local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end

vim.keymap.set("n", "<C-=>", function()
  change_scale_factor(1.1)
end)

vim.keymap.set("n", "<C-->", function()
  change_scale_factor(1 / 1.11)
end)


-- auto change dir when using GUI mode
vim.g.rooter_manual_only = 0

-- some transparency
-- vim.o.winblend = 10
-- vim.o.pumblend = 10
local bg_alpha = function()
  return string.format("%x", math.floor(255 * (vim.g.transparency)))
end
-- vim.g.neovide_transparency = 0.0
-- vim.g.transparency = 0.9
-- vim.g.neovide_background_color = "#0f1117" .. bg_alpha()

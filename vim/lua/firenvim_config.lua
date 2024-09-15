-- TODO (tai.le): this works, but the UX is not good, we load too much plugins
-- for using on the browser just too edit markdown
vim.g.firenvim_config = {
  globalSettings = {
    alt = "all",
    ignoreKeys = {
      all = { "<C-->" },
      normal = {
        "<D-1>",
        "<D-2>",
        "<D-3>",
        "<D-4>",
        "<D-5>",
        "<D-6>",
        "<D-7>",
        "<D-8>",
        "<D-9>",
        "<D-0>",
        "<D-t>",
      },
    },
  },
  localSettings = {
    [".*"] = {
      takeover = "never",
      cmdline = "neovim",
    },
  },
}

if vim.g.started_by_firenvim == true then
  -- Allow clipboard copy paste in neovim
  vim.g.neovide_input_use_logo = 1
  vim.api.nvim_set_keymap("", "<D-c>", '"+y', { noremap = true, silent = true }) -- Copy
  vim.api.nvim_set_keymap("", "<D-v>", "+p<CR>", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("!", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("t", "<D-v>", "<C-R>+", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("v", "<D-v>", "<C-R>+", { noremap = true, silent = true })

  -- Make navigating long lines easier in the tight view
  vim.api.nvim_set_keymap("n", "j", "gj", { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "k", "gk", { noremap = true, silent = true })

  -- vim.o.guifont = "Fira Code Nerd Font:h9"
  vim.o.guifont = "FiraCode Nerd Font:h8"

  -- disable various UI elements to have more text lines.
  vim.o.showtabline = 1
  vim.o.showmode = false
  vim.o.signcolumn = "no"
  vim.o.showcmd = false
  vim.o.linespace = -2
  vim.cmd("colo carbonfox")

  vim.api.nvim_create_autocmd({ "UIEnter" }, {
    callback = function()
      print("uienter here")
      local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
      if client ~= nil and client.name == "Firenvim" then
        vim.o.laststatus = 2
        vim.o.spell = true
      end

      vim.fn.timer_start(100, function()
        if vim.o.lines < 20 then
          vim.o.lines = 30
        end
        if vim.o.columns < 100 then
          vim.o.columns = 100
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd({ "BufEnter" }, {
    pattern = { "*" },
    callback = function()
      vim.o.filetype = "markdown"
    end,
  })

  -- avoid auto format move this line
end

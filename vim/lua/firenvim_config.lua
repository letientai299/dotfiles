vim.g.firenvim_config = {
  globalSettings = { alt = "all" },
  localSettings = {
    [".*"] = {
      cmdline = "neovim",
      takeover = "never",
    },
  },
}

if vim.g.started_by_firenvim == true then
  vim.o.guifont = "IosevkaTerm Nerd Font Light:h12"
  vim.api.nvim_create_autocmd({ "UIEnter" }, {
    callback = function(event)
      local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
      if client ~= nil and client.name == "Firenvim" then
        vim.o.laststatus = 0
        vim.cmd("silent CocDisable")
      end
    end,
  })

  vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
    callback = function(e)
      if vim.g.timer_started == true then
        return
      end
      vim.g.timer_started = true
      vim.fn.timer_start(10000, function()
        vim.g.timer_started = false
        write
      end)
    end
  })
end

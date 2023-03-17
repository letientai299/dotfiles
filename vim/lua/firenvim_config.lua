vim.g.firenvim_config = {
	globalSettings = { alt = "all" },
	localSettings = {
		[".*"] = {
			cmdline = "neovim",
			takeover = "never",
		},
	},
}

-- font

vim.api.nvim_create_autocmd({ "UIEnter" }, {
	callback = function(event)
		local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
		if client ~= nil and client.name == "Firenvim" then
			vim.o.laststatus = 0
			vim.o.guifont = "IosevkaTerm Nerd Font Light:h12"
      vim.cmd('silent CocDisable')
      vim.cmd('set filetype=markdown')
		end
	end,
})

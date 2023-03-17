-- TODO (tai.le): this works, but the UX is not good, we load too much plugins
-- for using on the browser just too edit markdown
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

  -- disable various UI elements to have more text lines.
	vim.o.showtabline = 1
	vim.o.showmode = 0
  vim.o.signcolumn = 'no'
  vim.o.showcmd = 0

	vim.api.nvim_create_autocmd({ "UIEnter" }, {
		callback = function(event)
			local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
			if client ~= nil and client.name == "Firenvim" then
				vim.o.laststatus = 0
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "BufEnter" }, {
		pattern = { "*" },
		callback = function()
			vim.o.filetype = "markdown"
		end,
	})

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		callback = function(e)
			if vim.g.timer_started == true then
				return
			end
			vim.g.timer_started = true
			vim.fn.timer_start(10000, function()
				vim.g.timer_started = false
				return "write" -- raise MR for this bug in their docs
			end)
		end,
	})
end

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
		},
	},
}

if vim.g.started_by_firenvim == true then
	vim.o.guifont = "IosevkaTerm Nerd Font Light:h11"

	-- disable various UI elements to have more text lines.
	vim.o.showtabline = 1
	vim.o.showmode = 0
	vim.o.signcolumn = "no"
	vim.o.showcmd = 0
	vim.o.spell = 1
	vim.o.linespace = -2
	vim.cmd("colo carbonfox")

	vim.api.nvim_create_autocmd({ "UIEnter" }, {
		callback = function(event)
			local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
			if client ~= nil and client.name == "Firenvim" then
				vim.o.laststatus = 0
			end

			vim.fn.timer_start(100, function()
				if vim.o.lines < 20 then
					vim.o.lines = 20
				end
				if vim.o.columns < 80 then
					vim.o.columns = 80
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

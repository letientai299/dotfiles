--------------------------------------------------------------------------------
-- alpha
--------------------------------------------------------------------------------
local alpha = require('alpha')
local cfg = require 'alpha.themes.startify'
cfg.section.header.val = {}
alpha.setup(cfg.config)

--------------------------------------------------------------------------------
-- nightfox
--------------------------------------------------------------------------------
-- local nightfox = require("nightfox")
-- nightfox.setup({
  -- options = {
    -- dim_inactive = true,
    -- styles = {
      -- -- Style to be applied to different syntax groups
      -- comments = "italic", -- Value is any valid attr-list value `:help attr-list`
      -- constants = "bold",
      -- keywords = "italic",
    -- },
    -- modules = { -- List of various plugins and additional options
      -- -- ...
    -- },
  -- },
  -- palettes = {},
  -- specs = {},
  -- groups = {},
-- })

-- nightfox.compile()

--------------------------------------------------------------------------------
-- catppuccin
--------------------------------------------------------------------------------
vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

-- fetch colors from g:catppuccin_flavour palette
local colors = require("catppuccin.palettes").get_palette()
require("catppuccin").setup({
  transparent_background = true,
  custom_highlights = {
    Comment = { fg = colors.lavender },
  },
  styles = {
    comments = { "italic" },
    keywords = { "italic" },
  },
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
      enable_ui = true,
    },
    indent_blankline = {
      enabled = true,
      colored_indent_levels = true,
      show_end_of_line = true,
      show_trailing_blankline_indent = true,
    },
    which_key = true,
    neotree = {
      enabled = true,
      show_root = true,
      transparent_panel = true,
    },
    coc_nvim = true,
  },
})
vim.cmd([[sil CatppuccinCompile]])

--------------------------------------------------------------------------------
-- tokyonight
--------------------------------------------------------------------------------
-- vim.g.tokyonight_colors = { comment = "#8c9fee" }
-- require("tokyonight").setup({
  -- styles = {
    -- comments = { italic = true },
    -- keywords = { italic = true },
    -- functions = {},
    -- variables = {},
    -- sidebars = "transparent",
    -- floats = "transparent",
  -- },
  -- sidebars = { "qf", "vista_kind", "terminal", "neo-tree" },
  -- transparent = true, -- Enable this to disable setting the background color
  -- hide_inactive_statusline = false,
  -- dim_inactive = true,
-- })

--------------------------------------------------------------------------------
-- toggleterm
--------------------------------------------------------------------------------
require("toggleterm").setup({
  direction = vim.g.neovide and "horizontal" or "float",
  insert_mappings = true,
  float_opts = {
    border = "curved",
  },
  open_mapping = [[<c-q>]],
})

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.cmd([[DisableWhitespace]])
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

--------------------------------------------------------------------------------
-- Gitsign
--------------------------------------------------------------------------------
require("gitsigns").setup({
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Keymaps
    map("n", "<leader>th", gs.preview_hunk)
    map("n", "<leader>tb", function()
      gs.blame_line({ full = true })
    end)

    map("n", "]c", function()
      if vim.wo.diff then
        return "]c"
      end
      vim.schedule(function()
        gs.next_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })

    map("n", "[c", function()
      if vim.wo.diff then
        return "[c"
      end
      vim.schedule(function()
        gs.prev_hunk()
      end)
      return "<Ignore>"
    end, { expr = true })
  end,
})

--------------------------------------------------------------------------------
-- icons
--------------------------------------------------------------------------------
require 'nvim-web-devicons'.setup {
  color_icons = true,

  default = true,

  override_by_extension = {
    ["rkt"] = {
      icon = "󰘧",
      color = "#f94449",
      name = "Racket",
    }
  },
}

--------------------------------------------------------------------------------
-- misc
--------------------------------------------------------------------------------
-- should call these after set colorscheme
require("todo-comments").setup({
  -- QUESTION
  -- Q:
  -- TODO
  -- HACK
  -- PERF
  -- NOTE
  -- TEST
  -- XXX
  -- FIX
  -- BUG
  -- ISSUE
  -- WARN
  keywords = {
    QUESTION = { icon = "؟", color = "question", alt = { "Q:" } },
  },

  highlight = {
    pattern = [[.*<(KEYWORDS).*:?]],
    comments_only = false,
  },

  colors = {
    info = { "#34eb92" },
    question = { "#c38bf7" },
  },

  search = {
    pattern = [[\b(KEYWORDS)\b.*:?]]
  },
})


require("bufferline").setup({
  options = {
    indicator = { style = "underline" },
    show_buffer_close_icons = false,
    show_close_icon = false,
    diagnostics_update_in_insert = true,
    diagnostics = "coc",
    separator_style = { '󰙏', '' },
  }
})

require("lualine").setup({
  options = {
    component_separators = {},
    section_separators = {},
  },
})

-- indent blank line
require("ibl").setup({
  scope = {
    enabled = false,
  }
})

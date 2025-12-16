--------------------------------------------------------------------------------
-- PERF: Alpha (dashboard) - Only load when nvim started without files
-- Deferred to VimEnter to properly detect if files were passed
-- Plugin is lazy-loaded via vim-plug's { 'on': [] }
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Only show alpha if no files opened and buffer is empty
    if vim.fn.argc() == 0 and vim.bo.buftype == "" and vim.fn.line("$") == 1 and vim.fn.getline(1) == "" then
      -- Load the plugin first (lazy-loaded by vim-plug)
      vim.cmd("call plug#load('alpha-nvim')")
      local alpha = require('alpha')
      local cfg = require 'alpha.themes.startify'
      cfg.section.header.val = {}
      alpha.setup(cfg.config)
      alpha.start(false)
    end
  end,
})

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
-- PERF: Load compiled colorscheme immediately, defer custom highlights
-- The colorscheme file is cached so this is fast.
-- Custom highlights are applied after UI is visible.
--------------------------------------------------------------------------------
vim.g.catppuccin_flavour = "macchiato" -- latte, frappe, macchiato, mocha

-- Load the colorscheme (uses cached/compiled version)
vim.cmd.colorscheme("catppuccin")

-- PERF: Defer custom catppuccin setup with palette colors
-- This runs after the UI is visible, so user sees the theme immediately
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
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
        integration = {
          dap = { enabled = true, enable_ui = true },
          indent_blankline = { enabled = true, colored_indent_levels = true },
          which_key = true,
          neotree = { enabled = true, show_root = true, transparent_panel = true },
          coc_nvim = true,
        },
      })
      -- Reapply colorscheme to pick up custom highlights
      vim.cmd.colorscheme("catppuccin")
    end, 100)  -- 100ms after UI visible
  end,
})

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
-- PERF: Lazy-loaded via vim-plug's 'on' option and keymap trigger
--------------------------------------------------------------------------------
local toggleterm_loaded = false
local function setup_toggleterm()
  if toggleterm_loaded then return end
  toggleterm_loaded = true
  require("toggleterm").setup({
    direction = vim.g.neovide and "horizontal" or "float",
    insert_mappings = true,
    float_opts = {
      border = "curved",
    },
    open_mapping = [[<c-q>]],
  })
end

-- PERF: Lazy load toggleterm on <C-q> keypress
vim.keymap.set({ "n", "t", "i" }, "<C-q>", function()
  setup_toggleterm()
  vim.cmd("ToggleTerm")
end, { desc = "Toggle terminal" })

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.cmd([[DisableWhitespace]])
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

--------------------------------------------------------------------------------
-- PERF: Deferred UI Plugin Loading
-- These plugins are not needed immediately at startup. Deferring them
-- allows the UI to appear faster (perceived performance improvement).
-- They load 50ms after VimEnter, which is imperceptible to users.
--------------------------------------------------------------------------------

local function setup_deferred_plugins()
  --------------------------------------------------------------------------------
  -- Gitsign (deferred)
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
  -- todo-comments (deferred)
  -- should call these after set colorscheme
  --------------------------------------------------------------------------------
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

  --------------------------------------------------------------------------------
  -- indent blank line (deferred)
  --------------------------------------------------------------------------------
  local ok, ibl = pcall(require, "ibl")
  if ok then
    ibl.setup({
      scope = {
        enabled = false,
      }
    })
  end
end

-- PERF: Defer non-essential UI plugins by 50ms after VimEnter.
-- This makes startup feel faster as the editor becomes usable immediately.
-- The deferred plugins will load in the background unnoticed.
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    -- Load gitsigns plugin first (lazy-loaded by vim-plug)
    vim.cmd("call plug#load('gitsigns.nvim')")
    vim.defer_fn(setup_deferred_plugins, 50)
  end,
})

--------------------------------------------------------------------------------
-- PERF: Essential UI Plugins - Load via deferred vim-plug loading
-- These affect visible interface but can load shortly after startup
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      -- Load plugins first (lazy-loaded by vim-plug)
      vim.cmd("call plug#load('lualine.nvim', 'bufferline.nvim')")

      -- icons - needed by bufferline and other UI elements
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

      -- lualine - status bar
      require("lualine").setup({
        options = {
          component_separators = {},
          section_separators = {},
        },
      })

      -- bufferline - tab bar
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
    end, 1)  -- 1ms delay - load immediately after VimEnter
  end,
})

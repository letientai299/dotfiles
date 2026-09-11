# oil.nvim: Hooking Mechanism and Lazy-Loading Analysis

## How oil.nvim intercepts `:e <dir>`

oil.nvim uses two cooperating autocmds registered in `setup()`:

### 1. `BufAdd` — the directory hijacker

```lua
vim.api.nvim_create_autocmd("BufAdd", {
  desc = "Detect directory buffer and open oil file browser",
  group = aug,
  pattern = "*",
  nested = true,
  callback = function(params)
    maybe_hijack_directory_buffer(params.buf)
  end,
})
```

`BufAdd` fires whenever Neovim adds a new buffer — including when `:e ./path/to/dir`
is run. The callback calls `maybe_hijack_directory_buffer()`:

```lua
local function maybe_hijack_directory_buffer(bufnr)
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then return false end
  if util.parse_url(bufname) or vim.fn.isdirectory(bufname) == 0 then
    return false
  end
  -- rename the buffer from "/path/to/dir" → "oil:///path/to/dir/"
  local new_name = util.addslash(
    config.adapter_to_scheme.files .. fs.os_to_posix_path(vim.fn.fnamemodify(bufname, ":p"))
  )
  local replaced = util.rename_buffer(bufnr, new_name)
  return not replaced
end
```

The function checks `vim.fn.isdirectory()` and, if true, renames the buffer from
the raw path to an `oil://` scheme URL. This rename is what makes the second
autocmd fire.

### 2. `BufReadCmd` — the content loader

```lua
vim.api.nvim_create_autocmd("BufReadCmd", {
  group = aug,
  pattern = scheme_pattern,   -- matches "oil://*"
  nested = true,
  callback = function(params)
    M.load_oil_buffer(params.buf)
  end,
})
```

After the hijack renames the buffer, Neovim needs to "read" the buffer. Because
the buffer name now matches `oil://*`, this `BufReadCmd` fires and
`load_oil_buffer()` populates the buffer with the directory listing. The
`nested = true` flag is required so that events triggered inside the callback
(e.g., `BufRead`, `FileType`) are not suppressed.

### The startup edge case

When Neovim is opened with a directory argument (`nvim .`) the startup buffer is
created *before* plugins load. oil handles this at the end of `setup()`:

```lua
local bufnr = vim.api.nvim_get_current_buf()
if maybe_hijack_directory_buffer(bufnr) and vim.v.vim_did_enter == 1 then
  -- BufReadCmd will NOT fire for a buffer that was already "read"
  -- before oil registered its autocmd, so load manually.
  M.load_oil_buffer(bufnr)
end
```

`vim.v.vim_did_enter` is `1` after `VimEnter` has fired. The comment documents
exactly why the manual call is needed: when `setup()` runs after Neovim has
already entered (i.e., the plugin was lazy-loaded), `BufReadCmd` never fires for
a buffer that was already read, so oil falls back to `load_oil_buffer()` directly.

---

## Startup timing: eager load vs lazy load

There are two distinct scenarios to handle:

| Scenario | What needs to work | Trigger available |
| --- | --- | --- |
| `nvim .` — directory on CLI at startup | The startup buffer is a directory before any plugin loads | Need `setup()` to run before `VimEnter`, or catch the buffer in `setup()` afterward using `vim_did_enter` check |
| `:e ./dir` — typed after Neovim is already running | Any new `BufAdd` fires → hijack works | Works as long as `setup()` ran at some point before the command |

For scenario 1, the startup buffer is created during Neovim's initialization
sequence, *before* `VimEnter` fires and *before* lazy-loaded plugins load.
The `BufAdd` autocmd that oil registers is not yet present, so Neovim reads the
directory buffer the normal (netrw) way. By the time a lazy plugin's `setup()`
runs, `BufReadCmd` for that buffer has already fired (or been skipped), and
`vim.v.vim_did_enter` is already `1`.

---

## Why lazy loading is officially not recommended

From the maintainer (stevearc), issue [#300][issue-300]:

> "Due to the complexity of properly lazy loading oil, I do not recommend it...
> there is no blessed path."

The official `lazy.nvim` config in the README includes an explicit comment:

```lua
{
  'stevearc/oil.nvim',
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {},
  dependencies = { { "nvim-mini/mini.icons", opts = {} } },
  -- Lazy loading is not recommended because it is very tricky to make it
  -- work correctly in all situations.
  lazy = false,
}
```

### Root causes

1. **Startup buffer race.** The directory buffer for `nvim .` is created before
   lazy plugins load. No `BufAdd` autocmd from oil exists yet, so netrw (or
   nothing) claims it.

2. **`BufReadCmd` fires once.** Once Neovim has "read" a buffer (even as an
   empty directory buffer), it will not re-fire `BufReadCmd` for that buffer.
   oil's `vim_did_enter` fallback calls `load_oil_buffer()` directly, but only
   if oil's `setup()` runs before the user dismisses the buffer.

3. **lazy.nvim's own startup window** (issue [#539][issue-539]). When lazy.nvim
   needs to install/update plugins it opens its own window. This interrupts the
   startup sequence before oil loads, so `nvim .` ends up with a blank buffer.

4. **`VimEnter` autocmd nesting quirk** (issue [#268][issue-268]). If you write
   a `VimEnter` autocmd that calls `require('oil').open()`, the buffer is empty
   because `BufReadCmd` is not fired from within `VimEnter` autocmd callbacks
   (autocmd nesting is suppressed by default). The workaround is
   `vim.schedule_wrap()`, which defers execution past the autocmd boundary:

   ```lua
   vim.api.nvim_create_autocmd("VimEnter", {
     callback = vim.schedule_wrap(function(data)
       require('oil').open()
     end),
   })
   ```

---

## What events/commands work for lazy loading (community findings)

Despite the "no blessed path" position, these approaches have been reported to
work with various caveats (issues [#75][issue-75], [#300][issue-300]):

### Approach A — `lazy = false` (recommended)

```lua
{ 'stevearc/oil.nvim', lazy = false, opts = {} }
```

Unconditionally loads oil at startup. Tiny overhead (~1–2 ms). No edge cases.

### Approach B — Events: `BufAdd` + `BufNew` pattern

```lua
{
  'stevearc/oil.nvim',
  event = { "BufAdd */", "BufNew */" },
  opts = {},
}
```

Triggers on any buffer add/new where the pattern ends with `/`. Catches `:e dir`
after startup, but **does not** catch `nvim .` because the startup buffer fires
`BufAdd` before lazy.nvim loads the plugin.

### Approach C — `VimEnter` + `BufNew`

```lua
{
  'stevearc/oil.nvim',
  event = { "VimEnter", "BufNew */" },
  opts = {},
}
```

`VimEnter` covers the `nvim .` case (barely — see nesting caveat above), and
`BufNew */` covers `:e dir` after startup. Still fragile because of the
`BufReadCmd` nesting issue inside `VimEnter`.

### Approach D — `+Oil` CLI workaround (not a config)

```bash
nvim "$(pwd)" +Oil
```

Forces oil to open after startup. Useful as an alias but not a general solution
for `:e dir` use.

---

## Summary

| Question | Answer |
| --- | --- |
| How does oil hook into `:e dir`? | `BufAdd` renames the buffer to `oil://…`; then `BufReadCmd` on `oil://*` loads the directory listing. |
| What's needed for `nvim .` at startup? | `setup()` must run before `VimEnter`, or oil's `vim_did_enter` fallback handles it — but only if setup ran quickly enough. `lazy = false` is the only reliable guarantee. |
| What's needed for `:e dir` after startup? | The `BufAdd` autocmd registered by `setup()` handles it automatically as long as oil has loaded at some point. |
| lazy.nvim events that cover `:e dir` (post-startup) | `BufAdd */` or `BufNew */` |
| lazy.nvim events that (imperfectly) cover `nvim .` | `VimEnter` with `vim.schedule_wrap` inside setup, or `lazy = false` |
| Official recommendation | `lazy = false` — no blessed lazy-loading path exists |

---

## References

- [oil.nvim GitHub][oil-github]
- [README lazy.nvim config example][oil-readme]
- [Issue #75 — lazy plugin manager support][issue-75]
- [Issue #268 — VimEnter empty buffer bug][issue-268]
- [Issue #300 — document/enable lazy loading][issue-300]
- [Issue #539 — breaks when lazy.nvim installs plugins][issue-539]
- [lazy.nvim issue #1049 — autocmd events not fired when lazy loading][lazy-issue-1049]

[oil-github]: https://github.com/stevearc/oil.nvim
[oil-readme]: https://github.com/stevearc/oil.nvim/blob/master/README.md
[issue-75]: https://github.com/stevearc/oil.nvim/issues/75
[issue-268]: https://github.com/stevearc/oil.nvim/issues/268
[issue-300]: https://github.com/stevearc/oil.nvim/issues/300
[issue-539]: https://github.com/stevearc/oil.nvim/issues/539
[lazy-issue-1049]: https://github.com/folke/lazy.nvim/issues/1049

## Authors

- Written by claude (claude-sonnet-4-6) at 2026-03-07 16:00

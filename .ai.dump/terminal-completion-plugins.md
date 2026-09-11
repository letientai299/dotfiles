# Neovim Terminal/Pane Completion Plugins

Research into plugins that complete text from terminal output, scrollback
buffers, or adjacent terminal panes (kitty/tmux).

## Kitty-Specific

### garyhurtz/cmp_kitty (nvim-cmp)

- **Stars:** 56
- **Language:** Lua
- **Last updated:** May 2024
- **URL:** <https://github.com/garyhurtz/cmp_kitty>

Uses kitty's remote control API (`kitty @ get-text`, `kitty @ ls`) to extract
content from other kitty windows/tabs. Requires `allow_remote_control` in
`kitty.conf`. Maintains a background cache that polls kitty windows periodically.

Key config:

- `extent`: `"all"` (scrollback + visible), `"screen"` (visible only), or
  `"selection"`
- Window filtering by activity, focus, title pattern, cwd, env vars, or
  foreground process
- Content matching: words, numbers, IPs, UUIDs, paths, URLs, files
- Timing: poll period, update cycle, item cache lifetime

This is the most relevant plugin for a kitty user. It reads from **all kitty
windows**, not just the one running neovim.

### garyhurtz/blink_cmp_kitty (blink.cmp)

- **Stars:** 6
- **Language:** Lua
- **Last updated:** Oct 2025
- **URL:** <https://github.com/garyhurtz/blink_cmp_kitty>

Same author, same approach, ported to [blink.cmp][blink] (a newer completion
framework). Filtering by OS window, tab, or individual window. Periodic cache
updates.

### custompro98/cmp-kitty (nvim-cmp)

- **Stars:** 0
- **Language:** Lua
- **Last updated:** May 2022
- **URL:** <https://github.com/custompro98/cmp-kitty>

Completes **kitty.conf keywords**, not terminal output. Unrelated to the use
case. Inactive (5 commits, no stars).

## Tmux-Specific

### andersevenrud/cmp-tmux (nvim-cmp)

- **Stars:** 126
- **Language:** Lua
- **Last updated:** Feb 2024
- **URL:** <https://github.com/andersevenrud/cmp-tmux>

Uses `tmux capture-pane` to pull text from adjacent panes (or all session
panes). Supports scrollback history via `capture_history = true`.

Key config:

- `all_panes`: source from all session panes vs adjacent only
- `capture_history`: include full scrollback
- `trigger_characters` / `trigger_characters_ft`
- `keyword_pattern`: regex for what counts as a word

Most popular in this category. Only works inside tmux.

### mgalliou/blink-cmp-tmux (blink.cmp)

- **Stars:** 10
- **Language:** Lua
- **Last updated:** Feb 2025
- **URL:** <https://github.com/mgalliou/blink-cmp-tmux>

Port of cmp-tmux for blink.cmp. Scope options: `"window"`, `"session"`, or
`"all"`. Supports `capture_history`.

## Shell History Sources

These complete from shell history rather than live terminal output:

- [CharlesTaylor7/cmp-nushell-history][nushell] -- nushell history
- [tamago324/cmp-zsh][zsh] -- zsh completions
- [mtoohey31/cmp-fish][fish] -- fish shell completions

## What Does NOT Exist

- **coc.nvim source for kitty or tmux panes.** No such plugin exists on GitHub.
- **nvim-cmp source for generic terminal scrollback** (terminal-emulator
  agnostic). Nothing found.
- **cmp-buffer variants that include terminal buffers.** The built-in
  `cmp-buffer` only reads neovim buffers. Neovim's `:terminal` buffers are
  technically included if listed, but scrollback from the external terminal
  emulator is not.

## Recommendation

For a kitty user who currently uses coc.nvim:

1. **Best fit: [garyhurtz/cmp_kitty][cmp-kitty].** Directly reads from kitty
   windows via remote control. Requires switching from coc.nvim to nvim-cmp (or
   using both side by side, which is messy).

2. **Future-proof: [garyhurtz/blink_cmp_kitty][blink-kitty].** Same approach but
   for blink.cmp, which is gaining traction as a faster nvim-cmp alternative.

3. **If also using tmux: [andersevenrud/cmp-tmux][cmp-tmux].** Can be combined
   with cmp_kitty for belt-and-suspenders coverage.

4. **coc.nvim path:** No existing plugin. You would need to write a custom
   coc.nvim source that shells out to `kitty @ get-text --match all` and parses
   the output. The kitty remote control API makes this feasible -- the hard part
   is tokenizing and deduplicating.

[blink]: https://github.com/Saghen/blink.cmp
[cmp-kitty]: https://github.com/garyhurtz/cmp_kitty
[blink-kitty]: https://github.com/garyhurtz/blink_cmp_kitty
[cmp-tmux]: https://github.com/andersevenrud/cmp-tmux
[nushell]: https://github.com/CharlesTaylor7/cmp-nushell-history
[zsh]: https://github.com/tamago324/cmp-zsh
[fish]: https://github.com/mtoohey31/cmp-fish

## Authors

- Written by claude (claude-opus-4-6) at 2026-03-01 15:30

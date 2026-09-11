# Kitty Terminal: Recent Features (v0.44-0.46)

Your installed version: **0.46.1**. All features below are available now.

---

## 1. Cursor Trail (v0.43+)

Animated trail that follows the text cursor on large jumps. Makes it easy to
track where the cursor landed after a big move.

```conf
cursor_trail 3
cursor_trail_decay 0.1 0.4
cursor_trail_start_threshold 2
```

- `cursor_trail` — milliseconds the cursor must stay still before trail
  activates. `0` disables. Values like `3` work well.
- `cursor_trail_decay` — two floats: fastest and slowest fade time in seconds.
- `cursor_trail_start_threshold` — minimum distance in cells before trail
  triggers. Default `2`.

**Status in your config:** commented out (`# cursor_trail 3`).

---

## 2. Smooth Pixel Scrolling (v0.46)

Per-pixel scrolling in the kitty scrollback buffer when using high-precision
input devices (touchpads, high-res scroll wheels). Replaces the old line-at-a-
time jumps.

```conf
pixel_scroll yes
```

Default is `yes` in 0.46, so it is already active unless explicitly disabled.

---

## 3. Momentum Scrolling (v0.46, Linux)

Inertial scrolling on Linux touchpads/touchscreens. The value controls friction
(0-1). Lower = more friction, stops faster.

```conf
momentum_scroll 0.96
```

Default `0.96`. macOS uses the OS-level momentum scrolling natively.

---

## 4. Tab Dragging (v0.46)

Drag tabs to reorder them, move to another OS window, or detach into a new
window. Configured via `tab_bar_drag_threshold` — the pixel distance the mouse
must move before a drag begins.

```conf
tab_bar_drag_threshold 20
```

A negative value disables tab dragging. Double-click a tab to rename it (also
new in 0.46).

---

## 5. Mouse-Based Window/Split Resizing (v0.46)

Drag window borders to resize splits in any layout. Controlled by
`window_drag_tolerance` — the tolerance in pts for the drag region around window
borders.

```conf
window_drag_tolerance 10
```

Works across all layouts including `splits`.

---

## 6. Command Palette (v0.46)

Browse and trigger all mapped and unmapped actions from a searchable palette.

```
Ctrl+Shift+F3
```

No config needed — built-in. Replaces your custom fzf keybinding shortcut
(alt+f3) for discovering keybindings, though the palette also covers unmapped
actions.

---

## 7. Choose-Files Kitten (v0.45)

Keyboard-first fuzzy file selector with syntax-highlighted previews, image
previews, video/e-book support. Replaces `fzf` for file picking in many
workflows.

```sh
kitten choose-files                    # single file
kitten choose-files --mode=files       # multi-select
kitten choose-files --mode=dir         # directory
kitten choose-files --mode=save-file   # save dialog
```

Key bindings inside the kitten:

| Action            | Key         |
| ----------------- | ----------- |
| Accept            | Enter       |
| Multi-select      | Shift+Enter |
| Enter directory   | Tab         |
| Go up             | Shift+Tab   |
| Toggle dotfiles   | Alt+H       |
| Toggle gitignored | Alt+I       |
| Toggle preview    | Alt+P       |

Shell integration shortcut: `Ctrl+Shift+P > C` (files) or `Ctrl+Shift+P > D`
(dirs).

Config file: `~/.config/kitty/choose-files.conf` for customization (show_hidden,
respect_ignores, pygments_style, etc.).

See the [official docs][choose-files].

---

## 8. copy_last_command_output Action (v0.45)

Copies the output of the last shell command to the clipboard. Requires shell
integration.

```conf
map ctrl+shift+o copy_last_command_output
```

---

## 9. search_scrollback Action (v0.45)

Opens the scrollback buffer directly in search mode (in your configured pager).

```conf
map ctrl+shift+/ search_scrollback
```

---

## 10. Paste Events Protocol (v0.45)

Support for the `bracketed-paste-mime` protocol. Programs can receive paste
events with MIME type information. No config needed — automatic for programs
that request it.

---

## 11. icat Improvements (v0.45)

- Animated PNG and WebP support
- netPBM format support
- ICC color profile support
- New `--fit` flag controlling image scaling behavior

```sh
kitten icat --fit=contain image.png
kitten icat --fit=shrink image.png    # only shrink, never enlarge
```

---

## 12. Window Title Bars per Window (v0.46)

Individual title bars for each kitty window (split), not just the OS window.

```conf
window_title_bar yes
```

---

## 13. OKLCH / LAB Color Support (v0.46)

Use perceptually uniform color spaces in `kitty.conf`:

```conf
foreground oklch(0.9 0.02 250)
background lab(10 0 -5)
```

---

## 14. Splits Layout Maximize (v0.46)

In the `splits` layout, you can now maximize/restore individual windows:

```conf
map ctrl+shift+z toggle_maximized
```

Already in your `enabled_layouts` list.

---

## 15. env Directive Enhancement (v0.44)

The `env` directive now reads specified environment variables from your login
shell at startup, so kitty picks up shell-specific env vars without being
launched from a shell.

```conf
env MY_VAR=
```

An empty value means "read from login shell."

---

## 16. Session File Improvements (v0.44-0.45)

- `focus_tab` command — specify which tab to focus by index or match expression
- `save_as_session --base-dir` — save sessions with relative paths
- `goto_session --directory` — pick session files from a directory
- `goto_session --sort-by=alphabetical` — fixed ordering

---

## 17. Wayland Background Blur (v0.46, Linux)

```conf
# Requires compositor support (KDE, Hyprland, etc.)
background_blur 1
```

---

## 18. macOS Dictation Support (v0.46)

Apple's native dictation input now works in kitty. No config needed.

---

## Summary: Quick Wins for Your Config

Features you could enable right now with minimal effort:

| Feature              | Config line                                 | Impact   |
| -------------------- | ------------------------------------------- | -------- |
| Cursor trail         | `cursor_trail 3`                            | Visual   |
| Command palette      | Built-in (Ctrl+Shift+F3)                    | Workflow |
| Choose-files kitten  | `kitten choose-files` (no config needed)    | Workflow |
| Copy last output     | `map ctrl+shift+o copy_last_command_output` | Workflow |
| Search scrollback    | `map ctrl+shift+/ search_scrollback`        | Workflow |
| Split maximize       | `map ctrl+shift+z toggle_maximized`         | Layout   |
| Window border resize | `window_drag_tolerance 10`                  | Layout   |

---

## Sources

- [Kitty changelog][changelog]
- [Kitty configuration reference][conf]
- [Choose-files kitten docs][choose-files]
- [Shell integration docs][shell-int]
- [Linuxiac: Kitty 0.46][linuxiac-046]
- [Linuxiac: Kitty 0.45][linuxiac-045]
- [Linuxiac: Kitty 0.44][linuxiac-044]

[changelog]: https://sw.kovidgoyal.net/kitty/changelog/
[conf]: https://sw.kovidgoyal.net/kitty/conf/
[choose-files]: https://sw.kovidgoyal.net/kitty/kittens/choose-files/
[shell-int]: https://sw.kovidgoyal.net/kitty/shell-integration/
[linuxiac-046]:
  https://linuxiac.com/kitty-0-46-terminal-emulator-released-with-smooth-scrolling-and-tab-dragging/
[linuxiac-045]:
  https://linuxiac.com/kitty-terminal-0-45-released-with-new-keyboard-first-file-selector-kitten/
[linuxiac-044]:
  https://linuxiac.com/kitty-terminal-0-44-released-with-unicode-17-support/

## Authors

- 2026-03-17 16:45: claude (claude-opus-4-6)
  [5b27bf9c-2a32-43d9-ba00-98b202c3689f] Research on kitty v0.44-0.46 features
  for config modernization

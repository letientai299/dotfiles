# fkill: killing process trees

## Context

Currently fkill lists flat processes. The user wants to select a parent (e.g.
`mise dev`) and kill the entire subtree (node servers, watchers, etc.).

## Question 1: Kill mechanism

Three main approaches for killing a process tree on macOS + Linux:

**A. Process group kill (`kill -- -$PGID`)**

- Processes started together often share a process group ID (PGID).
- `kill -- -$PGID` kills the entire group in one syscall.
- Pros: simple, fast, atomic, built-in.
- Cons: PGID doesn't always match the tree. A child that calls `setsid()` or
  `setpgid()` escapes the group. mise/npm/node generally stay in the same group,
  but it's not guaranteed.

**B. Walk the process tree (recursive `ppid` lookup)**

- Build a parent→children map from `ps -eo pid,ppid`, then recursively collect
  all descendants of the selected PID.
- Kill bottom-up (leaves first) to prevent orphan reparenting.
- Pros: accurate, works regardless of PGID/session boundaries.
- Cons: more code, small race window (new children can spawn between listing and
  killing), needs multiple kill calls.

**C. Hybrid: try PGID first, fall back to tree walk**

- Check if the selected process is the process group leader (`PID == PGID`).
- If yes, `kill -- -$PGID` (fast path).
- If no, fall back to tree walk.
- Pros: best of both.
- Cons: slightly more complexity.

**Answer:** C

## Question 2: UX — how to expose tree kill

Options for how the user triggers tree-kill in fzf:

**A. Always kill the tree (default behavior)**

- Selecting a process always kills it + all descendants.
- Simple mental model. Rarely do you want to kill a parent but leave children
  running (they'd become zombies anyway).

**B. Keybinding toggle**

- `enter` kills just the process. A separate key (e.g. `ctrl-t`) kills the tree.
- More control, but adds cognitive load.

**C. Tree view in fzf with auto-select children**

- Show processes as an indented tree. Selecting a parent auto-highlights its
  children.
- Visually clear, but harder to implement in fzf (fzf doesn't natively support
  tree selection). Would need to fake it with indentation + post-selection
  expansion.

**Answer:** A

## Question 3: Display format

Should the flat list change to show hierarchy?

**A. Keep flat list, tree-kill is invisible**

- List stays as-is. When you select a process, its descendants are killed
  silently. Output after kill confirms what was killed.

**B. Add indented tree view**

- Show process hierarchy with indentation (like `pstree`). Easier to see
  relationships. Tradeoff: uses more horizontal space, and root-level system
  processes add noise.

**C. Flat by default, `ctrl-t` toggles tree view**

- Best of both — flat for quick filtering, tree for understanding hierarchy.

**Answer:** B

## Authors

- Written by claude (claude-opus-4-6) at 2026-03-03 12:00

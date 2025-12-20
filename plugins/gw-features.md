# `gw` - Git Worktree Wrapper Tool

## Overview

`gw` is a convenience wrapper around `git worktree` that simplifies worktree management with automatic path handling, fuzzy finding, and shell integration.

---

## Features

### 1. Automatic Path Handling

**Problem**: Standard `git worktree add` requires manual path selection (e.g., `../some-path`), which is difficult when deep in the repository.

**Solution**: Worktrees are automatically placed as **sibling directories** to the repository root using a snake-case naming convention.

**Naming Pattern**: `<repo-name>.<branch-in-snake-case>`

**Examples**:
| Repository | Branch | Worktree Directory |
|------------|--------|-------------------|
| `dotfiles` | `tai/fix/slow-startup` | `dotfiles.tai-fix-slow-startup` |
| `myproject` | `feature/login` | `myproject.feature-login` |
| `nettest` | `main` | `nettest.main` |

---

### 2. Worktree Creation: `gw <branch-name>`

Creates a new worktree and changes directory to it.

**Behavior**:

- If the branch **does not exist**: Create the branch first, then create the worktree
- If the branch **exists**: Create a worktree for the existing branch
- After creation: **cd into the new worktree**

**Base Branch**:

- Default: The **current branch** (HEAD)
- Override with `-f` or `--from <base-branch>` to specify a different base

**Examples**:

```bash
# Create worktree from current branch
gw feature/new-thing

# Create worktree from specific base branch
gw feature/new-thing --from main
gw feature/new-thing -f develop
```

---

### 3. Worktree Selection: `gw` (no arguments)

When invoked without arguments, `gw` uses **fzf** to:

1. List all existing worktrees
2. Allow fuzzy selection
3. **cd into the selected worktree**

---

### 4. Worktree Removal: `gw --remove [target]`

Removes a worktree.

**Behavior**:

- If `target` is provided: Remove the specified worktree
- If `target` is **not provided**: Use **fzf** to select which worktree to remove
- If currently inside the worktree being removed:
  - Use **fzf** to select another worktree to switch to
  - If no other worktrees exist (besides main), switch to the **main worktree** (original clone)

**Examples**:

```bash
# Remove specific worktree
gw --remove feature/old-thing

# Remove with fzf selection
gw --remove
```

---

### 5. Tab Completion

**For `gw <branch>`**:

- Completes both **existing worktrees** AND **branches**

**For `gw --remove`**:

- Completes **only existing worktrees** (not branches)

---

### 6. Shell Integration

Since a script cannot directly change the shell's current directory, `gw` requires shell integration.

**Requirements**:

- A shell function (bash/zsh) that wraps the `gw` script
- The function evaluates/sources output from `gw` to perform `cd`

**Setup**: Instructions and the shell function will be provided with the tool.

---

## Command Summary

| Command                     | Description                                                       |
| --------------------------- | ----------------------------------------------------------------- |
| `gw`                        | List worktrees with fzf and cd to selection                       |
| `gw <branch>`               | Create worktree for branch (create branch if needed) and cd to it |
| `gw <branch> -f <base>`     | Create worktree with branch based on `<base>`                     |
| `gw <branch> --from <base>` | Same as above                                                     |
| `gw --remove`               | Remove worktree (fzf selection)                                   |
| `gw --remove <target>`      | Remove specified worktree                                         |

---

## Dependencies

- `git`
- `fzf`
- `bash` or `zsh`

#!/usr/bin/env python3
import json
import subprocess
import os
import hashlib
import tempfile

from kitty_shared import PROJECT_COLORS, get_project_color, find_git_root_and_dir

GIT_ICON = ""


def _ansi_color(hex_color, bold=False):
    r = (hex_color >> 16) & 0xFF
    g = (hex_color >> 8) & 0xFF
    b = hex_color & 0xFF
    prefix = "1;" if bold else ""
    return f"\033[{prefix}38;2;{r};{g};{b}m"


def _project_from_title(title):
    if not title.startswith("["):
        return None
    end = title.find("]")
    if end <= 1:
        return None
    return title[1:end].strip()


def _get_project_title(cwd):
    """Get '[project] task' title for a CWD, or None."""
    if not cwd:
        return None
    root, git_dir = find_git_root_and_dir(cwd)
    if not root or not git_dir:
        return None

    project_name = os.path.basename(root)
    title = f'[{project_name}]'

    git_dir_hash = hashlib.md5(git_dir.encode()).hexdigest()
    task_file = os.path.join(tempfile.gettempdir(), f'kitty-task-{git_dir_hash}')
    try:
        if os.path.exists(task_file):
            with open(task_file) as f:
                task_desc = f.read().strip().split('\n')[0].strip()
            if task_desc:
                title = f'[{project_name}] {task_desc}'
    except OSError:
        pass

    return title


def _relative_dir(cwd, git_root):
    """Get the directory path relative to git root, or '.' for root itself."""
    if not git_root or not cwd:
        return cwd or ''
    rel = os.path.relpath(cwd, git_root)
    return rel if rel != '.' else ''


def _is_self(cmdline_list):
    """Check if a cmdline is this script or its launcher."""
    text = " ".join(cmdline_list)
    return "switch.py" in text


def _is_overlay_self(window):
    """Check if this window is the overlay running switch.py."""
    for proc in window.get('foreground_processes', []):
        if _is_self(proc.get('cmdline') or []):
            return True
    return False


def _extract_process(window):
    """Get the running process name, ignoring this script's own process chain."""
    base_cmdline = window.get('cmdline') or []
    fg_processes = window.get('foreground_processes', [])

    # Use the deepest foreground process that isn't switch.py/fzf
    for proc in reversed(fg_processes):
        cmd = proc.get('cmdline') or []
        if cmd and not _is_self(cmd):
            name = os.path.basename(cmd[0]).lstrip('-')
            if name != 'fzf':
                return name

    # Fall back to base process
    if base_cmdline:
        return os.path.basename(base_cmdline[0]).lstrip('-')
    return window.get('title') or 'process'


def main():
    try:
        cmd = ['kitty', '@', 'ls']
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        data = json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running kitty @ ls: {e}")
        input("Press Enter to continue...")
        return
    except FileNotFoundError:
        print("kitty command not found. Make sure 'allow_remote_control yes' is in your kitty.conf")
        input("Press Enter to continue...")
        return

    rows = []
    for os_window in data:
        for tab in os_window.get('tabs', []):
            panes = []
            active_cwd = None

            for window in tab.get('windows', []):
                # Skip the overlay pane running this script
                if _is_overlay_self(window):
                    continue

                win_id = window.get('id')
                raw_cwd = window.get('cwd') or ''
                process = _extract_process(window)

                if window.get('is_active') or window.get('is_focused'):
                    active_cwd = raw_cwd

                root, _ = find_git_root_and_dir(raw_cwd)
                repo = os.path.basename(root) if root else None
                rel_dir = _relative_dir(raw_cwd, root)
                panes.append({
                    'id': win_id,
                    'repo': repo,
                    'rel_dir': rel_dir,
                    'process': process,
                })

            if not panes:
                continue

            # Derive tab title: try each window's CWD for a project title.
            # Prefer active window, fall back to any window in a git repo.
            display_title = None
            all_cwds = [w.get('cwd', '') for w in tab.get('windows', [])]
            if active_cwd:
                display_title = _get_project_title(active_cwd)
            if not display_title:
                for cwd in all_cwds:
                    title = _get_project_title(cwd)
                    if title:
                        display_title = title
                        break
            if not display_title:
                display_title = tab.get('title') or 'Tab'

            project = _project_from_title(display_title)
            tab_color = get_project_color(project) if project else 0x6ea8fe
            tab_row = f"{_ansi_color(tab_color, bold=True)}{display_title}\033[0m"
            rows.append(f"{panes[0]['id']}\ttab\t{tab_row}")

            for pane_idx, pane in enumerate(panes, start=1):
                if pane['repo']:
                    repo_col = f"{_ansi_color(0x8be9fd, bold=True)}{pane['repo']}\033[0m"
                    dir_col = (
                        f" {_ansi_color(0x50fa7b)}{pane['rel_dir']}\033[0m"
                        if pane['rel_dir'] else ""
                    )
                else:
                    repo_col = f"{_ansi_color(0x666666)}-\033[0m"
                    dir_col = ""
                pane_row = (
                    f"  "
                    f"{_ansi_color(0xf1fa8c, bold=True)}{pane_idx:>2}\033[0m "
                    f"{repo_col}{dir_col} "
                    f"{_ansi_color(0xbd93f9)}{pane['process']}\033[0m"
                )
                rows.append(f"{pane['id']}\tpane\t{pane_row}")

    if not rows:
        return
    fzf_input = "\n".join(rows)

    fzf_cmd = [
        'fzf',
        '--ansi',
        '--delimiter', '\t',
        '--with-nth', '3',
        '--header', 'Select Kitty pane',
        '--layout=reverse',
        '--border',
        '--prompt', 'Go to > ',
        '--preview', 'kitty @ get-text --match id:{1} --ansi --extent screen',
        '--preview-window', 'right,65%,border-left'
    ]

    try:
        fzf = subprocess.Popen(fzf_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        stdout, _ = fzf.communicate(input=fzf_input)

        if fzf.returncode == 0 and stdout.strip():
            selected_line = stdout.strip()
            selected_id = selected_line.split('\t', 1)[0]
            subprocess.run(['kitty', '@', 'focus-window', '--match', f'id:{selected_id}'], check=True)

    except FileNotFoundError:
        print("fzf not found. Please install fzf.")
        input("Press Enter to continue...")
        return
    except subprocess.CalledProcessError as e:
        print(f"Error switching window: {e}")
        input("Press Enter to continue...")


if __name__ == "__main__":
    main()

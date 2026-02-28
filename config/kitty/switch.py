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


def _get_tab_name_aliases(cwd):
    if not cwd:
        return []

    root, git_dir = find_git_root_and_dir(cwd)
    if not root or not git_dir:
        return []

    project_name = os.path.basename(root)
    aliases = [project_name, f'[{project_name}]']

    git_dir_hash = hashlib.md5(git_dir.encode()).hexdigest()
    task_file = os.path.join(tempfile.gettempdir(), f'kitty-task-{git_dir_hash}')

    try:
        if os.path.exists(task_file):
            with open(task_file) as f:
                task_desc = f.read().strip().split('\n')[0].strip()
            if task_desc:
                aliases.extend([task_desc, f'[{project_name}] {task_desc}'])
    except OSError:
        pass

    return aliases


def _pretty_cwd(cwd):
    if not cwd:
        return "-"
    home = os.path.expanduser('~')
    if cwd.startswith(home):
        return '~' + cwd[len(home):]
    return cwd


def _extract_process_and_cmd(window):
    cmdline_list = window.get('cmdline') or []
    fg_processes = window.get('foreground_processes', [])
    if fg_processes:
        proc = fg_processes[-1]
        cmdline_list = proc.get('cmdline') or cmdline_list
    cmdline = " ".join(cmdline_list)
    process = os.path.basename(cmdline_list[0]).lstrip('-') if cmdline_list else (window.get('title') or "process")
    return process or "process", cmdline


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
            tab_title = tab.get('title') or 'Tab'
            panes = []
            display_title = tab_title

            for window in tab.get('windows', []):
                win_id = window.get('id')
                win_title = window.get('title') or 'Window'
                raw_cwd = window.get('cwd') or ''
                process, cmdline = _extract_process_and_cmd(window)

                if "switch.py" in cmdline:
                    continue

                # Set display_title from the first pane only (#15)
                if not panes:
                    if display_title == "python3" and win_title != "python3":
                        display_title = win_title
                    tab_aliases = _get_tab_name_aliases(raw_cwd)
                    formatted_alias = next((a for a in reversed(tab_aliases) if a.startswith('[')), None)
                    if formatted_alias:
                        display_title = formatted_alias

                root, _ = find_git_root_and_dir(raw_cwd)
                repo = os.path.basename(root) if root else None
                panes.append({
                    'id': win_id,
                    'repo': repo,
                    'cwd': _pretty_cwd(raw_cwd),
                    'process': process,
                })

            if not panes:
                continue

            project = _project_from_title(display_title)
            tab_color = get_project_color(project) if project else 0x6ea8fe
            tab_row = f"{_ansi_color(tab_color, bold=True)}{display_title}\033[0m"
            rows.append(f"{panes[0]['id']}\ttab\t{tab_row}")

            for pane_idx, pane in enumerate(panes, start=1):
                # Show git icon only for git repos (#16)
                repo_col = (
                    f"{_ansi_color(0x8be9fd, bold=True)}{pane['repo']}\033[0m "
                    f"{_ansi_color(0x999999)}[{GIT_ICON}]\033[0m "
                    if pane['repo']
                    else f"{_ansi_color(0x666666)}-\033[0m "
                )
                pane_row = (
                    f"  "
                    f"{_ansi_color(0xf1fa8c, bold=True)}{pane_idx:>2}\033[0m "
                    f"{repo_col}"
                    f"{_ansi_color(0x50fa7b)}{pane['cwd']}\033[0m "
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

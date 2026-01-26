#!/usr/bin/env python3
import json
import subprocess
import os

def main():
    try:
        # Get kitty window data
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

    entries = []
    for os_window in data:
        for tab in os_window.get('tabs', []):
            tab_title = tab.get('title') or 'Tab'
            for window in tab.get('windows', []):
                win_id = window.get('id')
                win_title = window.get('title') or 'Window'
                cwd = window.get('cwd') or ''

                # Get the command
                cmdline_list = window.get('cmdline') or []

                # Check foreground processes to get the actual running command (e.g. vim instead of zsh)
                fg_processes = window.get('foreground_processes', [])
                if fg_processes:
                    # Use the last process in the list as it's likely the active one
                    proc = fg_processes[-1]
                    cmdline_list = proc.get('cmdline') or cmdline_list

                cmdline = " ".join(cmdline_list)

                # Filter out the switcher script itself
                if "switch.py" in cmdline:
                    continue

                # Pretty print CWD
                if cwd:
                    home = os.path.expanduser('~')
                    if cwd.startswith(home):
                        cwd = '~' + cwd[len(home):]

                # Handle misleading tab title (e.g. if it shows 'python3' because of the switcher)
                # If the tab title is 'python3', fall back to the window title
                display_title = tab_title
                if display_title == "python3" and win_title != "python3":
                    display_title = win_title

                entries.append({
                    'id': win_id,
                    'tab': display_title,
                    'cwd': cwd,
                    'cmd': cmdline
                })

    if not entries:
        return

    # Calculate widths for alignment
    max_tab_len = max((len(e['tab']) for e in entries), default=0)
    max_cwd_len = max((len(e['cwd']) for e in entries), default=0)

    candidates = []
    for e in entries:
        # Format: Tab (Blue) -> Cwd (Green) running Command (Cyan)
        tab_str = e['tab'].ljust(max_tab_len)
        cwd_str = e['cwd'].ljust(max_cwd_len)

        display_text = f"\033[1;34m{tab_str}\033[0m \033[90m->\033[0m \033[1;32m{cwd_str}\033[0m \033[90mrunning\033[0m \033[36m{e['cmd']}\033[0m"
        candidates.append(f"{e['id']} | {display_text}")

    if not candidates:
        return

    fzf_input = "\n".join(candidates)

    fzf_cmd = [
        'fzf',
        '--ansi',
        '--delimiter', r' \| ',
        '--with-nth', '2..',
        '--header', 'Select Kitty window',
        '--layout=reverse',
        '--border',
        '--prompt', 'Go to > '
    ]

    try:
        fzf = subprocess.Popen(fzf_cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)
        stdout, _ = fzf.communicate(input=fzf_input)

        if fzf.returncode == 0 and stdout.strip():
            selected_line = stdout.strip()
            # Extract ID (first field)
            selected_id = selected_line.split(' | ')[0]

            # Switch to the selected window
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

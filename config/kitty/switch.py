#!/usr/bin/env python3
import json
import subprocess
import sys
import os

def main():
    try:
        # Get kitty window data
        # We use kitty @ ls to get the state of all windows
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

    candidates = []
    
    for os_window in data:
        for tab in os_window.get('tabs', []):
            tab_title = tab.get('title', '')
            tab_id = tab.get('id')
            for window in tab.get('windows', []):
                win_id = window.get('id')
                win_title = window.get('title', '')
                cwd = window.get('cwd', '')
                cmdline = " ".join(window.get('cmdline', []))
                
                # Create a display string for fzf
                # We include the ID at the start for easy extraction
                # Format: ID | Tab Title | Window Title | CWD | Command
                
                # Shorten CWD to last 2 components if possible
                if cwd:
                    parts = cwd.strip('/').split('/')
                    if len(parts) > 2:
                        short_cwd = os.path.join(parts[-2], parts[-1])
                    else:
                        short_cwd = cwd
                else:
                    short_cwd = ""

                display = f"{win_id} | {tab_title} | {win_title} | {short_cwd} | {cmdline}"
                candidates.append(display)

    if not candidates:
        print("No windows found")
        return

    # Prepare input for fzf
    fzf_input = "\n".join(candidates)
    
    try:
        # Run fzf
        # --with-nth 2.. hides the first field (ID) from display but keeps it for selection
        # --delimiter " \| " splits fields by " | "
        fzf_cmd = ['fzf', '--delimiter', ' \| ', '--with-nth', '2..', '--header', 'Select a window to switch to']
        
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

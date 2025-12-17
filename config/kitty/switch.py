#!/usr/bin/env python3
import json
import subprocess
import sys
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

    candidates = []
    for os_window in data:
        for tab in os_window.get('tabs', []):
            tab_title = tab.get('title') or 'Tab'
            for window in tab.get('windows', []):
                win_id = window.get('id')
                win_title = window.get('title') or 'Window'
                cmdline = " ".join(window.get('cmdline') or [])
                
                # Filter out the switcher script itself
                if "switch.py" in cmdline:
                    continue
                
                # Format: ID | Display String
                # We will tell fzf to use " | " as delimiter and show from 2nd field onwards
                
                # Fancy tree-like display
                # [Tab Title] └─ [Window Title] (Command)
                
                # Colors:
                # Tab: Magenta (35)
                # Separator: Yellow (33)
                # Window: Green (32)
                # Command: Grey (90)
                
                display_text = f"\033[1;35m{tab_title}\033[0m \033[33m└─\033[0m \033[1;32m{win_title}\033[0m \033[90m({cmdline})\033[0m"
                candidates.append(f"{win_id} | {display_text}")

    if not candidates:
        return

    fzf_input = "\n".join(candidates)
    
    fzf_cmd = [
        'fzf', 
        '--ansi', 
        '--delimiter', ' \| ', 
        '--with-nth', '2..', 
        '--header', 'Select Window',
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

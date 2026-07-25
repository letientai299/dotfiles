"""Shared utilities for kitty tab_bar.py and switch.py."""
import hashlib
import os
import tempfile

PROJECT_COLORS = [
    0x50fa7b,  # Green
    0xff79c6,  # Pink
    0x8be9fd,  # Cyan
    0xffb86c,  # Orange
    0xbd93f9,  # Purple
    0xf1fa8c,  # Yellow
    0xff6e6e,  # Coral
    0x69ff94,  # Mint
    0xa4ffff,  # Light cyan
    0xff92df,  # Light pink
    0xffd580,  # Light orange
    0xcaa9fa,  # Light purple
]


def get_project_color(name):
    """Get a deterministic color for a project name using stable hash."""
    h = int(hashlib.md5(name.encode()).hexdigest(), 16)
    return PROJECT_COLORS[h % len(PROJECT_COLORS)]


def tab_task_file(tab_id):
    """Path to a tab's task file, keyed by kitty's stable tab id.

    The id is stable per session and independent of tab index, so reordering
    tabs keeps the same file. This makes the task pane-independent and free of
    any git-repo requirement.
    """
    return os.path.join(tempfile.gettempdir(), f'kitty-task-tab-{tab_id}')


def read_tab_task(tab_id):
    """Return the one-line task description for a tab id, or None."""
    try:
        with open(tab_task_file(tab_id)) as f:
            first = f.read().strip().split('\n', 1)[0].strip()
        return first or None
    except OSError:
        return None


def find_git_root_and_dir(cwd):
    """Walk up from cwd to find git root and git dir.

    Returns (root, git_dir) or (None, None).
    """
    path = cwd
    while path and path != os.path.dirname(path):
        git_path = os.path.join(path, '.git')
        if os.path.isdir(git_path):
            return path, git_path
        elif os.path.isfile(git_path):
            try:
                with open(git_path) as f:
                    line = f.read().strip()
                if line.startswith('gitdir: '):
                    git_dir = line[8:]
                    if not os.path.isabs(git_dir):
                        git_dir = os.path.normpath(os.path.join(path, git_dir))
                    return path, git_dir
            except Exception:
                pass
            return None, None
        path = os.path.dirname(path)
    return None, None

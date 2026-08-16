"""Custom tab bar for Kitty with slanted powerline tabs"""
import glob
import os
import sys
import tempfile
import time

from kitty.fast_data_types import Screen, get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    TabAccessor,
    as_rgb,
)

# kitty loads this file via runpy.run_path(), which — unlike running a script
# directly — does NOT put its directory on sys.path. Without this the sibling
# kitty_shared import below raises ModuleNotFoundError and kitty silently falls
# back to the default tab bar. https://docs.python.org/3/library/runpy.html
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from kitty_shared import (
    find_git_root_and_dir,
    get_project_color,
    read_tab_task,
)

# --- Shared constants ---

_TASK_CACHE_TTL = 10          # Git task info TTL (seconds)
_TASK_CACHE_MAX = 64          # Max CWDs to cache

_BORING_PROCESSES = frozenset({
    'sh', 'bash', 'zsh', 'fish', 'dash', 'ksh', 'tcsh', 'csh',
})


# --- Git project info for the auto-refreshing tab fallback ---
#
# The per-tab task (get_project_color / PROJECT_COLORS / find_git_root_and_dir /
# read_tab_task) lives in kitty_shared. Project detection below only feeds the
# fallback label shown when a tab has neither a manual title nor a task.

_task_cache = {}
_tab_project_cache = {}  # {tab_id: project_name} — last known project per tab

# Prune task files for tabs that no longer exist (e.g. after a tab closes). Done
# lazily here rather than via a close watcher, since a watcher can't reliably
# tell an overlay closing (set-tab-task.sh runs nvim in one) from a tab closing.
_TASK_FILE_PREFIX = os.path.join(tempfile.gettempdir(), 'kitty-task-tab-')
_TASK_PRUNE_INTERVAL = 5   # seconds
_last_task_prune = 0


def _prune_task_files(boss):
    """Delete kitty-task-tab-<id> files whose tab id is no longer live."""
    global _last_task_prune
    now = time.time()
    if now - _last_task_prune < _TASK_PRUNE_INTERVAL:
        return
    _last_task_prune = now
    try:
        live = {tab.id for tab in boss.all_tabs}
    except Exception:
        return
    for path in glob.glob(_TASK_FILE_PREFIX + '*'):
        suffix = path[len(_TASK_FILE_PREFIX):]
        if suffix.isdigit() and int(suffix) not in live:
            try:
                os.remove(path)
            except OSError:
                pass


def _dim_color(color_int, factor=0.45):
    """Dim a color by a factor for inactive tabs."""
    r = int(((color_int >> 16) & 0xFF) * factor)
    g = int(((color_int >> 8) & 0xFF) * factor)
    b = int((color_int & 0xFF) * factor)
    return (r << 16) | (g << 8) | b


def _get_project_name(cwd):
    """Get the git project name for a cwd, with caching, or None."""
    now = time.time()

    if cwd in _task_cache:
        ts, proj = _task_cache[cwd]
        if now - ts < _TASK_CACHE_TTL:
            return proj

    # Evict oldest entries when cache is full
    if len(_task_cache) >= _TASK_CACHE_MAX:
        oldest_key = min(_task_cache, key=lambda k: _task_cache[k][0])
        del _task_cache[oldest_key]

    root, git_dir = find_git_root_and_dir(cwd)
    if not root or not git_dir:
        # Don't cache non-git CWDs — transient paths like "/" appear briefly
        # during shell prompt hooks (e.g. git status) and would poison the cache.
        return None

    project_name = os.path.basename(root)
    _task_cache[cwd] = (now, project_name)
    return project_name


# --- Tab bar drawing ---


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_title_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw tab with folder path and process name with custom powerline drawing."""
    ta = TabAccessor(tab.tab_id)
    cwd = ta.active_wd

    # Get the best process name
    process = ta.active_exe or ta.active_oldest_exe or tab.title
    if process and os.path.basename(process).lstrip('-') in _BORING_PROCESSES:
        oldest = ta.active_oldest_exe
        if oldest and os.path.basename(oldest).lstrip('-') not in _BORING_PROCESSES:
            process = oldest
        elif tab.title and not any(tab.title.startswith(b) for b in _BORING_PROCESSES):
            process = tab.title.split()[0] if ' ' in tab.title else tab.title

    if process:
        process = os.path.basename(process).lstrip('-')

    # Check for manual tab title
    boss = get_boss()
    _prune_task_files(boss)
    tab_obj = boss.tab_for_id(tab.tab_id)
    has_manual_title = tab_obj and tab_obj.name

    # Per-tab task, keyed by the stable tab id — pane-independent and git-free.
    task_desc = None if has_manual_title else read_tab_task(tab.tab_id)

    # Auto-refreshing fallback: git project of the active pane's cwd, shown only
    # when the tab has neither a manual title nor a task. This intentionally
    # updates as you switch panes (for adhoc, unscoped tabs).
    project_name = None
    if not has_manual_title and not task_desc and cwd:
        # If the active window is an overlay, use the parent's CWD instead
        # to avoid transient overlays (e.g. switch.py) changing the tab title.
        effective_cwd = cwd
        if tab_obj:
            active_window = tab_obj.active_window
            if active_window:
                overlay_parent = getattr(active_window, 'overlay_parent', None)
                if overlay_parent is not None:
                    parent_cwd = getattr(overlay_parent, 'cwd_of_child', None)
                    if parent_cwd:
                        effective_cwd = parent_cwd

        project_name = _get_project_name(effective_cwd)
        if project_name:
            # Remember last known project for this tab
            _tab_project_cache[tab.tab_id] = project_name
        elif tab.tab_id in _tab_project_cache:
            # CWD is transiently non-git (e.g. "/" during prompt hooks) —
            # reuse the last known project for this tab.
            project_name = _tab_project_cache[tab.tab_id]

    # Tab colors
    if tab.is_active:
        bg = 0x1a3a6a
        fg = 0xffffff
    else:
        bg = 0x2a2a2a
        fg = 0x999999

    screen.cursor.bg = as_rgb(bg)
    screen.cursor.fg = as_rgb(fg)
    screen.draw(' ')

    if has_manual_title:
        title_text = tab.title
        if len(title_text) > max_title_length:
            title_text = title_text[:max_title_length - 1] + '…'
        screen.draw(title_text)

    elif task_desc:
        # Custom color from the task text — stable per task, same on every pane.
        task_color = get_project_color(task_desc)
        if len(task_desc) > max_title_length:
            task_desc = task_desc[:max_title_length - 1] + '…'
        screen.cursor.fg = as_rgb(
            task_color if tab.is_active else _dim_color(task_color)
        )
        screen.draw(task_desc)

    elif project_name:
        proj_color = get_project_color(project_name)
        bracket_fg = 0x888888 if tab.is_active else 0x777777

        if len(project_name) + 2 > max_title_length:
            project_name = project_name[:max_title_length - 3] + '…'

        screen.cursor.fg = as_rgb(bracket_fg)
        screen.draw('[')
        screen.cursor.fg = as_rgb(proj_color)
        screen.draw(project_name)
        screen.cursor.fg = as_rgb(bracket_fg)
        screen.draw(']')

    elif cwd:
        home = os.path.expanduser('~')
        if cwd.startswith(home):
            cwd = '~' + cwd[len(home):]
        parts = [p for p in cwd.split('/') if p]
        if len(parts) > 1:
            cwd = parts[-1]
        elif parts:
            cwd = '/'.join(parts)

        if tab.is_active:
            icon_color_rgb = (255, 255, 255)
            folder_color_rgb = (255, 230, 180)
            process_color_rgb = (210, 255, 210)
        else:
            icon_color_rgb = (200, 200, 200)
            folder_color_rgb = (220, 200, 160)
            process_color_rgb = (180, 220, 180)

        folder_icon = '\uf07c '

        screen.cursor.fg = as_rgb(process_color_rgb[0] << 16 | process_color_rgb[1] << 8 | process_color_rgb[2])
        screen.draw(process)
        screen.draw(' ')
        screen.cursor.fg = as_rgb(icon_color_rgb[0] << 16 | icon_color_rgb[1] << 8 | icon_color_rgb[2])
        screen.draw(folder_icon)
        screen.cursor.fg = as_rgb(folder_color_rgb[0] << 16 | folder_color_rgb[1] << 8 | folder_color_rgb[2])
        screen.draw(cwd)

    else:
        screen.draw(tab.title)

    screen.draw(' ')

    if is_last:
        screen.cursor.bg = as_rgb(0x000000)
        screen.cursor.fg = as_rgb(fg)
        remaining = screen.columns - screen.cursor.x
        if remaining > 0:
            screen.draw(' ' * remaining)

    return screen.cursor.x

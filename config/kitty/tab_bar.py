"""Custom tab bar for Kitty with slanted powerline tabs and system stats"""
import subprocess
import json
import hashlib
import os
import re
import tempfile
import time as _time
from datetime import datetime
from kitty.fast_data_types import Screen, get_options, get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_powerline,
)
from kitty.utils import color_as_int

opts = get_options()

# Shared cache file for all kitty processes
CACHE_FILE = os.path.join(tempfile.gettempdir(), 'kitty_tab_stats.json')

# Refresh intervals (in seconds)
STATS_REFRESH_INTERVAL = 1  # CPU, Memory, Network stats refresh interval
VPN_REFRESH_INTERVAL = 15    # VPN status refresh interval (changes less frequently)

def _load_cache():
    """Load cached stats from shared file"""
    try:
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    return {
        'cpu': (0.0, 0.0),
        'memory': (0.0, 0.0),
        'network': (0.0, 0.0),
        'vpn': None,
        'timestamp': 0
    }

def _save_cache(data):
    """Save stats to shared cache file"""
    try:
        with open(CACHE_FILE, 'w') as f:
            json.dump(data, f)
    except Exception:
        pass


def _get_cpu_usage():
    """Get CPU usage as (user%, sys%) - cross platform, non-blocking"""
    try:
        import os
        import time
        
        # Load from shared cache on first call
        if not hasattr(_get_cpu_usage, 'prev_idle'):
            cache = _load_cache()
            _get_cpu_usage.prev_idle = 0
            _get_cpu_usage.prev_total = 0
            _get_cpu_usage.last_check = cache.get('timestamp', 0)
            _get_cpu_usage.cached_value = tuple(cache.get('cpu', (0.0, 0.0)))
        
        # Only update every STATS_REFRESH_INTERVAL seconds
        now = time.time()
        if now - _get_cpu_usage.last_check < STATS_REFRESH_INTERVAL:
            return _get_cpu_usage.cached_value
        
        if os.path.exists('/proc/stat'):
            # Linux - read CPU times (instant, no subprocess)
            with open('/proc/stat', 'r') as f:
                line = f.readline()
                fields = line.split()
                user = int(fields[1])
                nice = int(fields[2])
                system = int(fields[3])
                idle = int(fields[4])
                total = sum(int(x) for x in fields[1:])
                
            # Calculate CPU usage from delta
            if _get_cpu_usage.prev_total > 0:
                user_delta = user + nice - getattr(_get_cpu_usage, 'prev_user', 0)
                sys_delta = system - getattr(_get_cpu_usage, 'prev_sys', 0)
                total_delta = total - _get_cpu_usage.prev_total
                
                if total_delta > 0:
                    user_percent = 100.0 * user_delta / total_delta
                    sys_percent = 100.0 * sys_delta / total_delta
                else:
                    user_percent, sys_percent = _get_cpu_usage.cached_value
            else:
                user_percent, sys_percent = 0.0, 0.0
            
            _get_cpu_usage.prev_user = user + nice
            _get_cpu_usage.prev_sys = system
            _get_cpu_usage.prev_idle = idle
            _get_cpu_usage.prev_total = total
            _get_cpu_usage.cached_value = (user_percent, sys_percent)
            _get_cpu_usage.last_check = now
            return (user_percent, sys_percent)
        else:
            # macOS - use top CPU summary, aligns better with Activity Monitor
            result = subprocess.run(
                ["top", "-l", "1", "-n", "0"],
                capture_output=True,
                text=True,
                timeout=0.8
            )
            for line in result.stdout.split('\n'):
                if not line.startswith('CPU usage:'):
                    continue
                try:
                    parts = line.split(':', 1)[1].split(',')
                    us = sy = None
                    for part in parts:
                        token = part.strip().split()
                        if len(token) < 2:
                            continue
                        value = float(token[0].rstrip('%'))
                        label = token[1].lower()
                        if label == 'user':
                            us = value
                        elif label == 'sys':
                            sy = value
                    if us is not None and sy is not None:
                        _get_cpu_usage.cached_value = (us, sy)
                        _get_cpu_usage.last_check = now
                        return (us, sy)
                except (ValueError, IndexError):
                    continue
            return _get_cpu_usage.cached_value
    except Exception:
        return getattr(_get_cpu_usage, 'cached_value', (0.0, 0.0))


def _get_memory_usage():
    """Get memory usage in GB"""
    try:
        import time
        
        # Load from shared cache on first call
        if not hasattr(_get_memory_usage, 'cached_value'):
            cache = _load_cache()
            mem_cache = cache.get('memory', (0.0, 0.0, 1, 0.0))
            while len(mem_cache) < 4:
                mem_cache = (*mem_cache, (1 if len(mem_cache) == 2 else 0.0))
            _get_memory_usage.cached_value = tuple(mem_cache)
            _get_memory_usage.last_check = cache.get('timestamp', 0)

        # Only update every STATS_REFRESH_INTERVAL seconds
        now = time.time()
        if now - _get_memory_usage.last_check < STATS_REFRESH_INTERVAL:
            return _get_memory_usage.cached_value
        
        # Use sysctl for total memory (faster) and vm_stat for detailed usage
        # Get total memory first (very fast: 0.003s)
        total_result = subprocess.run(
            ["sysctl", "-n", "hw.memsize"],
            capture_output=True,
            text=True,
            timeout=0.2
        )
        total = int(total_result.stdout.strip()) / (1024 ** 3)  # Convert to GB
        
        # Get memory pressure level (1=normal, 2=warn, 4=critical)
        pressure_level = 1
        try:
            p_result = subprocess.run(
                ["sysctl", "-n", "kern.memorystatus_vm_pressure_level"],
                capture_output=True,
                text=True,
                timeout=0.2
            )
            pressure_level = int(p_result.stdout.strip())
        except Exception:
            pass

        # Get swap usage (output: "total = 2048.00M  used = 374.38M  free = ...")
        swap_used_bytes = 0
        try:
            sw_result = subprocess.run(
                ["sysctl", "-n", "vm.swapusage"],
                capture_output=True,
                text=True,
                timeout=0.2
            )
            m = re.search(r'used\s*=\s*([\d.]+)M', sw_result.stdout)
            if m:
                swap_used_bytes = float(m.group(1)) * 1024 * 1024
        except Exception:
            pass

        # Get memory usage from vm_stat (fast: 0.004s)
        result = subprocess.run(
            ["vm_stat"],
            capture_output=True,
            text=True,
            timeout=0.3
        )
        lines = result.stdout.split('\n')

        page_size = 4096
        active = wired = compressed = 0

        for line in lines:
            if 'page size of' in line:
                page_size = int(line.split()[-2])
            elif 'Pages active' in line:
                active = int(line.split()[-1].rstrip('.'))
            elif 'Pages wired down' in line:
                wired = int(line.split()[-1].rstrip('.'))
            elif 'Pages occupied by compressor' in line or 'Pages stored in compressor' in line:
                compressed = int(line.split()[-1].rstrip('.'))

        # Activity Monitor "Memory Used" ~ app + wired + compressed
        used = (active + wired + compressed) * page_size / (1024 ** 3)

        # Pressure % ≈ (compressed + swap) / total — how much VM work the system does
        total_bytes = total * (1024 ** 3)
        compressed_bytes = compressed * page_size
        pressure_pct = (compressed_bytes + swap_used_bytes) / total_bytes * 100 if total_bytes > 0 else 0

        _get_memory_usage.cached_value = (used, total, pressure_level, pressure_pct)
        _get_memory_usage.last_check = now
        return used, total, pressure_level, pressure_pct
    except Exception:
        return getattr(_get_memory_usage, 'cached_value', (0.0, 0.0, 1, 0.0))


def _get_network_stats():
    """Get network bandwidth usage (bytes/sec) - cross platform"""
    try:
        import os
        import time
        
        # Load from shared cache on first call
        if not hasattr(_get_network_stats, 'prev_rx'):
            cache = _load_cache()
            _get_network_stats.prev_rx = 0
            _get_network_stats.prev_tx = 0
            _get_network_stats.prev_time = cache.get('timestamp', time.time())
            cached_net = cache.get('network', (0.0, 0.0))
            _get_network_stats.rx_rate = cached_net[0] * 1024  # Convert back to bytes
            _get_network_stats.tx_rate = cached_net[1] * 1024
        
        rx_bytes = 0
        tx_bytes = 0
        
        if os.path.exists('/proc/net/dev'):
            # Linux
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if ':' not in line or line.strip().startswith('lo:'):
                        continue
                    parts = line.split(':')
                    if len(parts) != 2:
                        continue
                    stats = parts[1].split()
                    if len(stats) >= 9:
                        rx_bytes += int(stats[0])
                        tx_bytes += int(stats[8])
        elif os.path.exists('/sys/class/net'):
            # Linux alternative
            for iface in os.listdir('/sys/class/net'):
                if iface == 'lo':
                    continue
                try:
                    with open(f'/sys/class/net/{iface}/statistics/rx_bytes', 'r') as f:
                        rx_bytes += int(f.read().strip())
                    with open(f'/sys/class/net/{iface}/statistics/tx_bytes', 'r') as f:
                        tx_bytes += int(f.read().strip())
                except:
                    continue
        else:
            # macOS - use netstat (very fast: 0.005s)
            result = subprocess.run(
                ["netstat", "-ibn"],
                capture_output=True,
                text=True,
                timeout=0.3  # Reduced timeout since it's fast
            )
            # Optimized parsing - skip header and lo0
            for line in result.stdout.split('\n'):
                if '<Link#' not in line or 'lo0' in line:
                    continue
                parts = line.split()
                if len(parts) >= 10:
                    try:
                        # Columns: Name Mtu Network Address Ipkts Ierrs Ibytes Opkts Oerrs Obytes
                        rx = parts[6]
                        tx = parts[9]
                        if rx.isdigit() and tx.isdigit():
                            rx_bytes += int(rx)
                            tx_bytes += int(tx)
                    except (ValueError, IndexError):
                        continue
        
        # Calculate rate (bytes per second)
        current_time = time.time()
        time_delta = current_time - _get_network_stats.prev_time
        
        if time_delta >= STATS_REFRESH_INTERVAL:  # Update every STATS_REFRESH_INTERVAL seconds
            rx_delta = rx_bytes - _get_network_stats.prev_rx
            tx_delta = tx_bytes - _get_network_stats.prev_tx
            
            _get_network_stats.rx_rate = rx_delta / time_delta if time_delta > 0 else 0
            _get_network_stats.tx_rate = tx_delta / time_delta if time_delta > 0 else 0
            
            _get_network_stats.prev_rx = rx_bytes
            _get_network_stats.prev_tx = tx_bytes
            _get_network_stats.prev_time = current_time
        
        # Convert to KB/s
        rx_kbs = _get_network_stats.rx_rate / 1024
        tx_kbs = _get_network_stats.tx_rate / 1024
        
        return rx_kbs, tx_kbs
    except Exception:
        return 0.0, 0.0


def _get_vpn_name():
    """Get active VPN connection name - cross platform, optimized"""
    try:
        import os
        import time
        
        # Load from shared cache on first call
        if not hasattr(_get_vpn_name, 'cached_value'):
            cache = _load_cache()
            _get_vpn_name.cached_value = cache.get('vpn')
            _get_vpn_name.last_check = cache.get('timestamp', 0)
        
        # Only update every VPN_REFRESH_INTERVAL seconds (VPN state changes rarely)
        now = time.time()
        if now - _get_vpn_name.last_check < VPN_REFRESH_INTERVAL:
            return _get_vpn_name.cached_value
        
        vpn_name = None
        
        if os.path.exists('/proc/net/dev'):
            # Linux - check for tun/tap interfaces
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if 'tun' in line or 'tap' in line:
                        iface = line.split(':')[0].strip()
                        vpn_name = iface
                        break
        else:
            # macOS - check for active VPN via scutil with status command (faster)
            result = subprocess.run(
                ["scutil", "--nc", "list"],
                capture_output=True,
                text=True,
                timeout=0.3  # Reduced timeout
            )
            # Early exit on first match
            for line in result.stdout.split('\n'):
                if '(Connected)' in line and '"' in line:
                    # Parse line like: "* (Connected)       ABCD1234-...  IPSec        "VPN Name""
                    parts = line.split('"')
                    if len(parts) >= 2:
                        name = parts[1]
                        # Ignore Tailscale VPN
                        if 'tailscale' not in name.lower():
                            vpn_name = name
                            break
        
        _get_vpn_name.cached_value = vpn_name
        _get_vpn_name.last_check = now
        
        # Save to shared cache
        _save_cache({
            'cpu': getattr(_get_cpu_usage, 'cached_value', (0.0, 0.0)),
            'memory': getattr(_get_memory_usage, 'cached_value', (0.0, 0.0)),
            'network': (getattr(_get_network_stats, 'rx_rate', 0.0) / 1024, 
                       getattr(_get_network_stats, 'tx_rate', 0.0) / 1024),
            'vpn': vpn_name,
            'timestamp': now
        })
        
        return vpn_name
    except Exception:
        return getattr(_get_vpn_name, 'cached_value', None)


def _get_net_type():
    """Detect active network type: 'wifi' or 'ethernet'"""
    try:
        import time

        if not hasattr(_get_net_type, 'cached_value'):
            _get_net_type.cached_value = 'wifi'
            _get_net_type.wifi_iface = None
            _get_net_type.last_check = 0

        now = time.time()
        if now - _get_net_type.last_check < VPN_REFRESH_INTERVAL:
            return _get_net_type.cached_value

        # Discover Wi-Fi interface name once
        if _get_net_type.wifi_iface is None:
            result = subprocess.run(
                ["networksetup", "-listallhardwareports"],
                capture_output=True, text=True, timeout=0.3
            )
            lines = result.stdout.split('\n')
            for i, line in enumerate(lines):
                if 'Wi-Fi' in line:
                    for next_line in lines[i + 1:i + 3]:
                        if next_line.startswith('Device:'):
                            _get_net_type.wifi_iface = next_line.split(':')[1].strip()
                            break
                    break
            if not _get_net_type.wifi_iface:
                _get_net_type.wifi_iface = 'en0'  # fallback

        # Check default route interface
        result = subprocess.run(
            ["route", "-n", "get", "default"],
            capture_output=True, text=True, timeout=0.3
        )
        for line in result.stdout.split('\n'):
            if 'interface:' in line:
                iface = line.split(':')[1].strip()
                _get_net_type.cached_value = 'wifi' if iface == _get_net_type.wifi_iface else 'ethernet'
                break

        _get_net_type.last_check = now
        return _get_net_type.cached_value
    except Exception:
        return getattr(_get_net_type, 'cached_value', 'wifi')


# --- Git project task info for tab rendering ---

# Cache: {cwd: (timestamp, project_name, task_desc)}
_task_cache = {}
_TASK_CACHE_TTL = 2  # seconds

# Bright colors with good contrast on dark backgrounds (0x1a1a1a / 0x3a3a3a)
_PROJECT_COLORS = [
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


def _get_project_color(name):
    """Get a deterministic color for a project name using stable hash"""
    h = int(hashlib.md5(name.encode()).hexdigest(), 16)
    return _PROJECT_COLORS[h % len(_PROJECT_COLORS)]


def _dim_color(color_int, factor=0.45):
    """Dim a color by a factor for inactive tabs"""
    r = int(((color_int >> 16) & 0xFF) * factor)
    g = int(((color_int >> 8) & 0xFF) * factor)
    b = int((color_int & 0xFF) * factor)
    return (r << 16) | (g << 8) | b


def _find_git_root_and_dir(cwd):
    """Walk up from cwd to find git root and git dir.
    Returns (root, git_dir) or (None, None).
    """
    path = cwd
    while path and path != os.path.dirname(path):
        git_path = os.path.join(path, '.git')
        if os.path.isdir(git_path):
            return path, git_path
        elif os.path.isfile(git_path):
            # Worktree: .git is a file containing "gitdir: <path>"
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


def _get_task_info(cwd):
    """Get (project_name, task_desc) for a cwd, with caching.
    Returns (None, None) if not in a git repo.
    """
    now = _time.time()

    if cwd in _task_cache:
        ts, proj, task = _task_cache[cwd]
        if now - ts < _TASK_CACHE_TTL:
            return proj, task

    root, git_dir = _find_git_root_and_dir(cwd)
    if not root or not git_dir:
        _task_cache[cwd] = (now, None, None)
        return None, None

    project_name = os.path.basename(root)
    task_desc = None

    # Deterministic tempfile path based on git dir (matches set-tab-task.sh)
    git_dir_hash = hashlib.md5(git_dir.encode()).hexdigest()
    task_file = os.path.join(tempfile.gettempdir(), f'kitty-task-{git_dir_hash}')
    try:
        if os.path.exists(task_file):
            with open(task_file) as f:
                content = f.read().strip()
            if content:
                task_desc = content.split('\n')[0].strip()
    except Exception:
        pass

    _task_cache[cwd] = (now, project_name, task_desc)
    return project_name, task_desc


def _draw_right_status(screen: Screen):
    """Draw system stats on the right side with color coding"""
    cpu_user, cpu_sys = _get_cpu_usage()
    mem_used, mem_total, mem_pressure, mem_pressure_pct = _get_memory_usage()
    rx_mb, tx_mb = _get_network_stats()
    
    # Get color based on percentage
    # Low: green, Mid: yellow, High: orange, Too high: red
    def get_color(percent):
        if percent < 50:
            return as_rgb(0x50fa7b)  # Green
        elif percent < 70:
            return as_rgb(0xf1fa8c)  # Yellow
        elif percent < 90:
            return as_rgb(0xffb86c)  # Orange
        else:
            return as_rgb(0xff5555)  # Red
    
    # Network - format KB/s or MB/s, right-justified to fixed width
    def format_network(kbs_value):
        if kbs_value >= 1024:
            return f"{kbs_value/1024:.1f}M"
        else:
            return f"{kbs_value:.0f}K"

    # Build stats with fixed-width text slots to prevent layout shifts
    stats_parts = []

    # CPU: "XXX%" → 4 chars max
    cpu_total = cpu_user + cpu_sys
    cpu_text = f"{cpu_total:.0f}%".rjust(4)
    stats_parts.append(("\uf085 ", get_color(cpu_total), cpu_text))

    # Memory: "XXX%" → 4 chars max
    if mem_pressure >= 4:
        pressure_color = as_rgb(0xff5555)  # Red
    elif mem_pressure >= 2:
        pressure_color = as_rgb(0xf1fa8c)  # Yellow
    else:
        pressure_color = as_rgb(0x50fa7b)  # Green
    mem_text = f"{mem_pressure_pct:.0f}%".rjust(4)
    stats_parts.append(("  \uf1c0 ", pressure_color, mem_text))

    # Network: icon reflects wifi vs ethernet, red if VPN active
    vpn_name = _get_vpn_name()
    net_type = _get_net_type()
    net_icon = "\uf1eb" if net_type == 'wifi' else "\uf0e8"  # fa-wifi / fa-sitemap
    network_icon_color = as_rgb(0xff5555) if vpn_name else as_rgb(0xcccccc)
    rx_text = f"{format_network(rx_mb).rjust(6)}\uf175"
    tx_text = f"{format_network(tx_mb).rjust(6)}\uf176"
    stats_parts.append((f"  {net_icon}  ", network_icon_color, as_rgb(0xaaaaaa), f"{rx_text} {tx_text}"))
    
    # Draw stats, then measure actual width to use as cached padding next time.
    # This avoids guessing icon display widths (symbol_map double-width is unreliable).
    if not hasattr(_draw_right_status, 'stats_width'):
        _draw_right_status.stats_width = 0

    # Build flat draw list: [(color_or_none, text), ...]
    draw_ops = []
    for item in stats_parts:
        if len(item) == 4:  # icon, icon_color, text_color, text
            icon, icon_color, text_color, text = item
            draw_ops.append((icon_color, icon))
            if text:
                draw_ops.append((text_color, text))
        else:  # icon, color, text
            icon, color, text = item
            draw_ops.append((color, icon))
            if text:
                draw_ops.append((color, text))

    # Use cached stats_width for right-aligned padding; skip on first render.
    if _draw_right_status.stats_width > 0:
        padding = screen.columns - screen.cursor.x - _draw_right_status.stats_width
        if padding > 0:
            screen.draw(" " * padding)

    default_fg = screen.cursor.fg
    before_x = screen.cursor.x
    for color, text in draw_ops:
        if color is not None:
            screen.cursor.fg = color
        screen.draw(text)

    # Update cached width from actual draw for next render
    _draw_right_status.stats_width = screen.cursor.x - before_x

    # Fill any remaining gap (first render or width change)
    remaining = screen.columns - screen.cursor.x
    if remaining > 0:
        screen.cursor.fg = default_fg
        screen.draw(" " * remaining)

    screen.cursor.fg = default_fg


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
    """Draw tab with folder path and process name with custom powerline drawing"""

    from kitty.tab_bar import TabAccessor
    import os

    ta = TabAccessor(tab.tab_id)
    cwd = ta.active_wd

    # Get the best process name
    process = ta.active_exe or ta.active_oldest_exe or tab.title
    boring_processes = {'sh', 'bash', 'zsh', 'fish', 'dash', 'ksh', 'tcsh', 'csh'}
    if process and os.path.basename(process).lstrip('-') in boring_processes:
        oldest = ta.active_oldest_exe
        if oldest and os.path.basename(oldest).lstrip('-') not in boring_processes:
            process = oldest
        elif tab.title and not any(tab.title.startswith(b) for b in boring_processes):
            process = tab.title.split()[0] if ' ' in tab.title else tab.title
    if process:
        process = os.path.basename(process).lstrip('-')

    # Check for manual tab title
    boss = get_boss()
    tab_obj = boss.tab_for_id(tab.tab_id)
    has_manual_title = tab_obj and tab_obj.name

    # Detect git project task info (only when no manual title)
    project_name, task_desc = (None, None)
    if not has_manual_title and cwd:
        project_name, task_desc = _get_task_info(cwd)

    # Tab colors
    if tab.is_active:
        bg = 0x3a3a3a
        fg = 0xffffff
    else:
        bg = 0x1a1a1a
        fg = 0x666666

    right_sep = '\ue0b0'
    tab_bar_bg = 0x1a1a1a

    screen.cursor.bg = as_rgb(bg)
    screen.cursor.fg = as_rgb(fg)
    screen.draw(' ')

    if has_manual_title:
        # Manual tab title (existing behavior)
        title_text = tab.title
        if len(title_text) > max_title_length:
            title_text = title_text[:max_title_length - 1] + '…'
        screen.draw(title_text)

    elif project_name:
        # Git project mode: [project_name] task_desc
        proj_color = _get_project_color(project_name)

        if tab.is_active:
            bracket_fg = 0x888888
            proj_fg = proj_color
            task_fg = 0xffffff
        else:
            bracket_fg = 0x444444
            proj_fg = _dim_color(proj_color, 0.45)
            task_fg = 0x666666

        # Truncate task_desc if needed
        prefix_len = len(project_name) + 2  # [name]
        if task_desc:
            full_len = prefix_len + 1 + len(task_desc)
            if full_len > max_title_length:
                avail = max_title_length - prefix_len - 1
                if avail > 1:
                    task_desc = task_desc[:avail - 1] + '…'
                else:
                    task_desc = None

        screen.cursor.fg = as_rgb(bracket_fg)
        screen.draw('[')
        screen.cursor.fg = as_rgb(proj_fg)
        screen.draw(project_name)
        screen.cursor.fg = as_rgb(bracket_fg)
        screen.draw(']')

        if task_desc:
            screen.cursor.fg = as_rgb(task_fg)
            screen.draw(' ' + task_desc)

    elif cwd:
        # CWD + process mode (fallback for non-git dirs)
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
            icon_color_rgb = (150, 150, 150)
            folder_color_rgb = (180, 160, 130)
            process_color_rgb = (140, 180, 140)

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

    # Draw right separator
    if is_last:
        screen.cursor.bg = as_rgb(0x000000)
        screen.cursor.fg = as_rgb(bg)
        screen.draw(right_sep)
        screen.cursor.bg = as_rgb(0x000000)
        _draw_right_status(screen)
    else:
        screen.cursor.bg = as_rgb(tab_bar_bg)
        screen.cursor.fg = as_rgb(bg)
        screen.draw(right_sep)

    return screen.cursor.x

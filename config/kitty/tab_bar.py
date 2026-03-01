"""Custom tab bar for Kitty with slanted powerline tabs and system stats"""
import ctypes
import ctypes.util
import hashlib
import json
import os
import re
import struct
import subprocess
import tempfile
import time

from kitty.fast_data_types import Screen, get_options, get_boss
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    TabAccessor,
    as_rgb,
)

opts = get_options()

# --- Shared constants ---

CACHE_FILE = os.path.join(tempfile.gettempdir(), 'kitty_tab_stats.json')
STATS_REFRESH_INTERVAL = 1   # CPU, Memory, Network refresh (seconds)
VPN_REFRESH_INTERVAL = 15    # VPN / net-type refresh (seconds)
_TASK_CACHE_TTL = 2           # Git task info TTL (seconds)
_TASK_CACHE_MAX = 64          # Max CWDs to cache

_BORING_PROCESSES = frozenset({
    'sh', 'bash', 'zsh', 'fish', 'dash', 'ksh', 'tcsh', 'csh',
})

# --- ctypes setup for macOS Mach/sysctl APIs ---

_libc = ctypes.CDLL(ctypes.util.find_library('c'))
_mach_host = _libc.mach_host_self()

# CPU: host_statistics with HOST_CPU_LOAD_INFO
_HOST_CPU_LOAD_INFO = 3
_CPU_STATE_MAX = 4
_CPU_STATE_USER = 0
_CPU_STATE_SYSTEM = 1
_CPU_STATE_IDLE = 2
_CPU_STATE_NICE = 3


class _HostCpuLoadInfo(ctypes.Structure):
    _fields_ = [('cpu_ticks', ctypes.c_uint32 * _CPU_STATE_MAX)]


# Memory: host_statistics64 with HOST_VM_INFO64
_HOST_VM_INFO64 = 4


class _VmStatistics64(ctypes.Structure):
    """Matches Darwin <mach/vm_statistics.h> — natural_t fields are uint32."""
    _fields_ = [
        ('free_count', ctypes.c_uint32),
        ('active_count', ctypes.c_uint32),
        ('inactive_count', ctypes.c_uint32),
        ('wire_count', ctypes.c_uint32),
        ('zero_fill_count', ctypes.c_uint64),
        ('reactivations', ctypes.c_uint64),
        ('pageins', ctypes.c_uint64),
        ('pageouts', ctypes.c_uint64),
        ('faults', ctypes.c_uint64),
        ('cow_faults', ctypes.c_uint64),
        ('lookups', ctypes.c_uint64),
        ('hits', ctypes.c_uint64),
        ('purges', ctypes.c_uint64),
        ('purgeable_count', ctypes.c_uint32),
        ('speculative_count', ctypes.c_uint32),
        ('decompressions', ctypes.c_uint64),
        ('compressions', ctypes.c_uint64),
        ('swapins', ctypes.c_uint64),
        ('swapouts', ctypes.c_uint64),
        ('compressor_page_count', ctypes.c_uint32),
        ('throttled_count', ctypes.c_uint32),
        ('external_page_count', ctypes.c_uint32),
        ('internal_page_count', ctypes.c_uint32),
        ('total_uncompressed_pages_in_compressor', ctypes.c_uint64),
    ]


# Page size (constant, read once)
_page_size_val = ctypes.c_uint64()
_libc.host_page_size(_mach_host, ctypes.byref(_page_size_val))
_PAGE_SIZE = _page_size_val.value

# Total physical memory (constant, read once)
_hw_memsize_buf = ctypes.create_string_buffer(8)
_hw_memsize_sz = ctypes.c_size_t(8)
_libc.sysctlbyname(b'hw.memsize', _hw_memsize_buf,
                    ctypes.byref(_hw_memsize_sz), None, 0)
_TOTAL_MEM_BYTES = struct.unpack('Q', _hw_memsize_buf.raw[:8])[0]
_TOTAL_MEM_GB = _TOTAL_MEM_BYTES / (1024 ** 3)


def _sysctlbyname_int(name, fmt='i'):
    """Read a sysctl value as an integer. fmt: 'i' for int32, 'Q' for uint64."""
    size = struct.calcsize(fmt)
    buf = ctypes.create_string_buffer(size)
    sz = ctypes.c_size_t(size)
    ret = _libc.sysctlbyname(name, buf, ctypes.byref(sz), None, 0)
    if ret != 0:
        return None
    return struct.unpack(fmt, buf.raw[:size])[0]


# xsw_usage struct for vm.swapusage: total, avail, used, encrypted (all uint64)
def _get_swap_used_bytes():
    """Read swap used via sysctl vm.swapusage."""
    buf = ctypes.create_string_buffer(256)
    sz = ctypes.c_size_t(256)
    ret = _libc.sysctlbyname(b'vm.swapusage', buf, ctypes.byref(sz), None, 0)
    if ret != 0 or sz.value < 24:
        return 0
    # struct xsw_usage { uint64 total, avail, used; }
    _total, _avail, used = struct.unpack('QQQ', buf.raw[:24])
    return used


# --- Shared cache for cross-process stats ---

def _load_cache():
    """Load cached stats from shared file."""
    try:
        if os.path.exists(CACHE_FILE):
            with open(CACHE_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    return {
        'cpu': (0.0, 0.0),
        'memory': (0.0, 0.0, 1, 0.0),
        'network': (0.0, 0.0),
        'vpn': None,
        'timestamp': 0,
    }


def _save_cache(data):
    """Save stats to shared cache file atomically."""
    try:
        tmp_fd, tmp_path = tempfile.mkstemp(
            dir=os.path.dirname(CACHE_FILE), suffix='.tmp'
        )
        with os.fdopen(tmp_fd, 'w') as f:
            json.dump(data, f)
        os.replace(tmp_path, CACHE_FILE)
    except Exception:
        try:
            os.unlink(tmp_path)
        except Exception:
            pass


# Load cache once at init; individual functions reference this dict.
_initial_cache = _load_cache()

# --- Stats collection functions ---


def _get_cpu_usage():
    """Get CPU usage as (user%, sys%) via Mach host_statistics (instant)."""
    try:
        if not hasattr(_get_cpu_usage, 'prev_ticks'):
            cached = tuple(_initial_cache.get('cpu', (0.0, 0.0)))
            _get_cpu_usage.cached_value = cached
            _get_cpu_usage.last_check = _initial_cache.get('timestamp', 0)
            _get_cpu_usage.prev_ticks = None

        now = time.time()
        if now - _get_cpu_usage.last_check < STATS_REFRESH_INTERVAL:
            return _get_cpu_usage.cached_value

        if os.path.exists('/proc/stat'):
            # Linux path (unchanged)
            with open('/proc/stat', 'r') as f:
                line = f.readline()
                fields = line.split()
                user = int(fields[1]) + int(fields[2])  # user + nice
                system = int(fields[3])
                total = sum(int(x) for x in fields[1:])

            prev = _get_cpu_usage.prev_ticks
            if prev:
                td = total - prev[2]
                if td > 0:
                    user_pct = 100.0 * (user - prev[0]) / td
                    sys_pct = 100.0 * (system - prev[1]) / td
                else:
                    user_pct, sys_pct = _get_cpu_usage.cached_value
            else:
                user_pct, sys_pct = 0.0, 0.0
            _get_cpu_usage.prev_ticks = (user, system, total)
        else:
            # macOS — ctypes host_statistics (instant, no subprocess)
            info = _HostCpuLoadInfo()
            count = ctypes.c_uint32(_CPU_STATE_MAX)
            ret = _libc.host_statistics(
                _mach_host, _HOST_CPU_LOAD_INFO,
                ctypes.byref(info), ctypes.byref(count)
            )
            if ret != 0:
                return _get_cpu_usage.cached_value

            t = info.cpu_ticks
            user = t[_CPU_STATE_USER] + t[_CPU_STATE_NICE]
            system = t[_CPU_STATE_SYSTEM]
            total = sum(t[i] for i in range(_CPU_STATE_MAX))

            prev = _get_cpu_usage.prev_ticks
            if prev:
                td = total - prev[2]
                if td > 0:
                    user_pct = 100.0 * (user - prev[0]) / td
                    sys_pct = 100.0 * (system - prev[1]) / td
                else:
                    user_pct, sys_pct = _get_cpu_usage.cached_value
            else:
                user_pct, sys_pct = 0.0, 0.0
            _get_cpu_usage.prev_ticks = (user, system, total)

        _get_cpu_usage.cached_value = (user_pct, sys_pct)
        _get_cpu_usage.last_check = now
        return (user_pct, sys_pct)
    except Exception:
        return getattr(_get_cpu_usage, 'cached_value', (0.0, 0.0))


def _get_memory_usage():
    """Get memory stats via ctypes (no subprocesses).

    Returns (used_gb, total_gb, pressure_level, pressure_pct).
    """
    try:
        if not hasattr(_get_memory_usage, 'cached_value'):
            mem_cache = _initial_cache.get('memory', (0.0, 0.0, 1, 0.0))
            while len(mem_cache) < 4:
                mem_cache = (*mem_cache, (1 if len(mem_cache) == 2 else 0.0))
            _get_memory_usage.cached_value = tuple(mem_cache)
            _get_memory_usage.last_check = _initial_cache.get('timestamp', 0)

        now = time.time()
        if now - _get_memory_usage.last_check < STATS_REFRESH_INTERVAL:
            return _get_memory_usage.cached_value

        # Pressure level (1=normal, 2=warn, 4=critical)
        pressure_level = _sysctlbyname_int(
            b'kern.memorystatus_vm_pressure_level'
        ) or 1

        # Swap used
        swap_used_bytes = _get_swap_used_bytes()

        # VM stats via host_statistics64
        info = _VmStatistics64()
        count = ctypes.c_uint32(ctypes.sizeof(info) // 4)
        ret = _libc.host_statistics64(
            _mach_host, _HOST_VM_INFO64,
            ctypes.byref(info), ctypes.byref(count)
        )
        if ret != 0:
            return _get_memory_usage.cached_value

        active_bytes = info.active_count * _PAGE_SIZE
        wired_bytes = info.wire_count * _PAGE_SIZE
        compressed_bytes = info.compressor_page_count * _PAGE_SIZE

        used_gb = (active_bytes + wired_bytes + compressed_bytes) / (1024 ** 3)
        pressure_pct = (
            (compressed_bytes + swap_used_bytes) / _TOTAL_MEM_BYTES * 100
            if _TOTAL_MEM_BYTES > 0 else 0
        )

        _get_memory_usage.cached_value = (
            used_gb, _TOTAL_MEM_GB, pressure_level, pressure_pct
        )
        _get_memory_usage.last_check = now
        return _get_memory_usage.cached_value
    except Exception:
        return getattr(_get_memory_usage, 'cached_value', (0.0, 0.0, 1, 0.0))


def _get_network_stats():
    """Get network bandwidth usage (KB/s) - cross platform."""
    try:
        if not hasattr(_get_network_stats, 'prev_rx'):
            cached_net = _initial_cache.get('network', (0.0, 0.0))
            _get_network_stats.prev_rx = 0
            _get_network_stats.prev_tx = 0
            _get_network_stats.prev_time = _initial_cache.get('timestamp', time.time())
            _get_network_stats.rx_rate = cached_net[0] * 1024
            _get_network_stats.tx_rate = cached_net[1] * 1024

        # Early return if cache is fresh (#3)
        now = time.time()
        if now - _get_network_stats.prev_time < STATS_REFRESH_INTERVAL:
            return _get_network_stats.rx_rate / 1024, _get_network_stats.tx_rate / 1024

        rx_bytes = 0
        tx_bytes = 0

        if os.path.exists('/proc/net/dev'):
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
            for iface in os.listdir('/sys/class/net'):
                if iface == 'lo':
                    continue
                try:
                    with open(f'/sys/class/net/{iface}/statistics/rx_bytes', 'r') as f:
                        rx_bytes += int(f.read().strip())
                    with open(f'/sys/class/net/{iface}/statistics/tx_bytes', 'r') as f:
                        tx_bytes += int(f.read().strip())
                except Exception:
                    continue
        else:
            # macOS
            result = subprocess.run(
                ["netstat", "-ibn"],
                capture_output=True, text=True, timeout=0.3
            )
            for line in result.stdout.split('\n'):
                if '<Link#' not in line or 'lo0' in line:
                    continue
                parts = line.split()
                if len(parts) >= 10:
                    try:
                        rx = parts[6]
                        tx = parts[9]
                        if rx.isdigit() and tx.isdigit():
                            rx_bytes += int(rx)
                            tx_bytes += int(tx)
                    except (ValueError, IndexError):
                        continue

        time_delta = now - _get_network_stats.prev_time
        if time_delta > 0:
            rx_delta = rx_bytes - _get_network_stats.prev_rx
            tx_delta = tx_bytes - _get_network_stats.prev_tx
            _get_network_stats.rx_rate = rx_delta / time_delta
            _get_network_stats.tx_rate = tx_delta / time_delta

        _get_network_stats.prev_rx = rx_bytes
        _get_network_stats.prev_tx = tx_bytes
        _get_network_stats.prev_time = now

        return _get_network_stats.rx_rate / 1024, _get_network_stats.tx_rate / 1024
    except Exception:
        return 0.0, 0.0


def _get_vpn_name():
    """Get active VPN connection name - cross platform, optimized."""
    try:
        if not hasattr(_get_vpn_name, 'cached_value'):
            _get_vpn_name.cached_value = _initial_cache.get('vpn')
            _get_vpn_name.last_check = _initial_cache.get('timestamp', 0)

        now = time.time()
        if now - _get_vpn_name.last_check < VPN_REFRESH_INTERVAL:
            return _get_vpn_name.cached_value

        vpn_name = None

        if os.path.exists('/proc/net/dev'):
            with open('/proc/net/dev', 'r') as f:
                for line in f:
                    if 'tun' in line or 'tap' in line:
                        vpn_name = line.split(':')[0].strip()
                        break
        else:
            result = subprocess.run(
                ["scutil", "--nc", "list"],
                capture_output=True, text=True, timeout=0.3
            )
            for line in result.stdout.split('\n'):
                if '(Connected)' in line and '"' in line:
                    parts = line.split('"')
                    if len(parts) >= 2:
                        name = parts[1]
                        if 'tailscale' not in name.lower():
                            vpn_name = name
                            break

        _get_vpn_name.cached_value = vpn_name
        _get_vpn_name.last_check = now
        return vpn_name
    except Exception:
        return getattr(_get_vpn_name, 'cached_value', None)


def _get_net_type():
    """Detect active network type: 'wifi' or 'ethernet'."""
    try:
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
                _get_net_type.wifi_iface = 'en0'

        result = subprocess.run(
            ["route", "-n", "get", "default"],
            capture_output=True, text=True, timeout=0.3
        )
        for line in result.stdout.split('\n'):
            if 'interface:' in line:
                iface = line.split(':')[1].strip()
                _get_net_type.cached_value = (
                    'wifi' if iface == _get_net_type.wifi_iface else 'ethernet'
                )
                break

        _get_net_type.last_check = now
        return _get_net_type.cached_value
    except Exception:
        return getattr(_get_net_type, 'cached_value', 'wifi')


# --- Shared cache save (called after all stats collected) ---

def _save_all_stats():
    """Write all current stats to the shared cache file."""
    _save_cache({
        'cpu': getattr(_get_cpu_usage, 'cached_value', (0.0, 0.0)),
        'memory': getattr(_get_memory_usage, 'cached_value', (0.0, 0.0, 1, 0.0)),
        'network': (
            getattr(_get_network_stats, 'rx_rate', 0.0) / 1024,
            getattr(_get_network_stats, 'tx_rate', 0.0) / 1024,
        ),
        'vpn': getattr(_get_vpn_name, 'cached_value', None),
        'timestamp': time.time(),
    })


# --- Git project task info for tab rendering ---

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

_task_cache = {}
_tab_project_cache = {}  # {tab_id: (project_name, task_desc)} — last known project per tab


def get_project_color(name):
    """Get a deterministic color for a project name using stable hash."""
    h = int(hashlib.md5(name.encode()).hexdigest(), 16)
    return PROJECT_COLORS[h % len(PROJECT_COLORS)]


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


def _dim_color(color_int, factor=0.45):
    """Dim a color by a factor for inactive tabs."""
    r = int(((color_int >> 16) & 0xFF) * factor)
    g = int(((color_int >> 8) & 0xFF) * factor)
    b = int((color_int & 0xFF) * factor)
    return (r << 16) | (g << 8) | b


def _get_task_info(cwd):
    """Get (project_name, task_desc) for a cwd, with caching."""
    now = time.time()

    if cwd in _task_cache:
        ts, proj, task = _task_cache[cwd]
        if now - ts < _TASK_CACHE_TTL:
            return proj, task

    # Evict oldest entries when cache is full
    if len(_task_cache) >= _TASK_CACHE_MAX:
        oldest_key = min(_task_cache, key=lambda k: _task_cache[k][0])
        del _task_cache[oldest_key]

    root, git_dir = find_git_root_and_dir(cwd)
    if not root or not git_dir:
        # Don't cache non-git CWDs — transient paths like "/" appear briefly
        # during shell prompt hooks (e.g. git status) and would poison the cache.
        return None, None

    project_name = os.path.basename(root)
    task_desc = None

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


# --- Status bar drawing helpers (module-level to avoid re-creation) ---

def _get_color(percent):
    """Color by percentage: green < 50, yellow < 70, orange < 90, red >= 90."""
    if percent < 50:
        return as_rgb(0x50fa7b)
    elif percent < 70:
        return as_rgb(0xf1fa8c)
    elif percent < 90:
        return as_rgb(0xffb86c)
    else:
        return as_rgb(0xff5555)


def _format_network(kbs_value):
    """Format KB/s as 'XXXXM' or 'XXXXK', right-justified to 6 chars."""
    if kbs_value >= 1024:
        return f"{kbs_value/1024:.1f}M"
    else:
        return f"{kbs_value:.0f}K"


# --- Tab bar drawing ---

# Cached stats width for right-alignment (updated after each draw)
_stats_width = 0
# Track last cache save time
_last_cache_save = 0


def _draw_right_status(screen: Screen):
    """Draw system stats on the right side with color coding."""
    global _stats_width, _last_cache_save

    cpu_user, cpu_sys = _get_cpu_usage()
    mem_used, mem_total, mem_pressure, mem_pressure_pct = _get_memory_usage()
    rx_kb, tx_kb = _get_network_stats()

    # Save cache every STATS_REFRESH_INTERVAL (not just on VPN check)
    now = time.time()
    if now - _last_cache_save >= STATS_REFRESH_INTERVAL:
        _save_all_stats()
        _last_cache_save = now

    # Build stats parts
    stats_parts = []

    # CPU
    cpu_total = cpu_user + cpu_sys
    cpu_text = f"{cpu_total:.0f}%".rjust(4)
    stats_parts.append(("\uf085 ", _get_color(cpu_total), cpu_text))

    # Memory pressure
    if mem_pressure >= 4:
        pressure_color = as_rgb(0xff5555)
    elif mem_pressure >= 2:
        pressure_color = as_rgb(0xf1fa8c)
    else:
        pressure_color = as_rgb(0x50fa7b)
    mem_text = f"{mem_pressure_pct:.0f}%".rjust(4)
    stats_parts.append(("  \uf1c0 ", pressure_color, mem_text))

    # Network
    vpn_name = _get_vpn_name()
    net_type = _get_net_type()
    net_icon = "\uf1eb" if net_type == 'wifi' else "\uf0e8"
    network_icon_color = as_rgb(0xff5555) if vpn_name else as_rgb(0xcccccc)
    rx_text = f"{_format_network(rx_kb).rjust(6)}\uf175"
    tx_text = f"{_format_network(tx_kb).rjust(6)}\uf176"
    stats_parts.append((
        f"  {net_icon}  ", network_icon_color,
        as_rgb(0xaaaaaa), f"{rx_text} {tx_text}"
    ))

    # Build flat draw list: [(color, text), ...]
    draw_ops = []
    for item in stats_parts:
        if len(item) == 4:
            icon, icon_color, text_color, text = item
            draw_ops.append((icon_color, icon))
            if text:
                draw_ops.append((text_color, text))
        else:
            icon, color, text = item
            draw_ops.append((color, icon))
            if text:
                draw_ops.append((color, text))

    # Right-align using cached width from previous render; skip on first render.
    if _stats_width > 0:
        padding = screen.columns - screen.cursor.x - _stats_width
        if padding > 0:
            screen.draw(" " * padding)

    default_fg = screen.cursor.fg
    before_x = screen.cursor.x
    for color, text in draw_ops:
        if color is not None:
            screen.cursor.fg = color
        screen.draw(text)

    _stats_width = screen.cursor.x - before_x

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
    tab_obj = boss.tab_for_id(tab.tab_id)
    has_manual_title = tab_obj and tab_obj.name

    # Detect git project task info (only when no manual title)
    project_name, task_desc = (None, None)
    if not has_manual_title and cwd:
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

        project_name, task_desc = _get_task_info(effective_cwd)
        if project_name:
            # Remember last known project for this tab
            _tab_project_cache[tab.tab_id] = (project_name, task_desc)
        elif tab.tab_id in _tab_project_cache:
            # CWD is transiently non-git (e.g. "/" during prompt hooks) —
            # reuse the last known project for this tab.
            project_name, task_desc = _tab_project_cache[tab.tab_id]

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
        title_text = tab.title
        if len(title_text) > max_title_length:
            title_text = title_text[:max_title_length - 1] + '…'
        screen.draw(title_text)

    elif project_name:
        proj_color = get_project_color(project_name)

        if tab.is_active:
            bracket_fg = 0x888888
            proj_fg = proj_color
            task_fg = 0xffffff
        else:
            bracket_fg = 0x444444
            proj_fg = _dim_color(proj_color, 0.45)
            task_fg = 0x666666

        prefix_len = len(project_name) + 2
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

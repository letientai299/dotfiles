"""Custom tab bar for Kitty with slanted powerline tabs and system stats"""
import subprocess
import json
import os
import tempfile
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
STATS_REFRESH_INTERVAL = 5  # CPU, Memory, Network stats refresh interval
VPN_REFRESH_INTERVAL = 30    # VPN status refresh interval (changes less frequently)

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
    """Get CPU usage as (user%, sys%) - cross platform"""
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
            # Linux - read CPU times
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
            # macOS - use iostat (much faster than top: ~0.015s vs ~0.7s)
            result = subprocess.run(
                ["iostat", "-c", "1", "-w", "1"],
                capture_output=True,
                text=True,
                timeout=0.5
            )
            # Parse iostat output - last line has CPU stats at the end
            # Format: disk_stats... us sy id load_avg...
            # Example: 44.33 1 0.03 ... 11 7 82 4.78 7.74 8.46
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 2:
                try:
                    stats = lines[-1].split()
                    if len(stats) >= 6:
                        # CPU stats are at: [-6]=us, [-5]=sy, [-4]=id
                        # (followed by 3 load averages at -3, -2, -1)
                        us = float(stats[-6])
                        sy = float(stats[-5])
                        # Validate they're reasonable percentages
                        if 0 <= us <= 100 and 0 <= sy <= 100:
                            _get_cpu_usage.cached_value = (us, sy)
                            _get_cpu_usage.last_check = now
                            return (us, sy)
                except (ValueError, IndexError):
                    pass
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
            _get_memory_usage.cached_value = tuple(cache.get('memory', (0.0, 0.0)))
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
        
        # Get memory usage from vm_stat (fast: 0.004s)
        result = subprocess.run(
            ["vm_stat"],
            capture_output=True,
            text=True,
            timeout=0.3
        )
        lines = result.stdout.split('\n')
        
        page_size = 4096
        active = wired = 0
        
        for line in lines:
            if 'page size of' in line:
                page_size = int(line.split()[-2])
            elif 'Pages active' in line:
                active = int(line.split()[-1].rstrip('.'))
            elif 'Pages wired down' in line:
                wired = int(line.split()[-1].rstrip('.'))
        
        # Only count active and wired as "used" (more accurate)
        used = (active + wired) * page_size / (1024 ** 3)
        
        _get_memory_usage.cached_value = (used, total)
        _get_memory_usage.last_check = now
        return used, total
    except Exception:
        return getattr(_get_memory_usage, 'cached_value', (0.0, 0.0))


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


def _draw_right_status(screen: Screen):
    """Draw system stats on the right side with color coding"""
    cpu_user, cpu_sys = _get_cpu_usage()
    mem_used, mem_total = _get_memory_usage()
    rx_mb, tx_mb = _get_network_stats()
    
    # Calculate memory percentage
    mem_percent = (mem_used / mem_total * 100) if mem_total > 0 else 0
    
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
    
    # Network - format KB/s or MB/s
    def format_network(kbs_value):
        if kbs_value >= 1024:
            return f"{kbs_value/1024:.1f}MB/s"
        else:
            return f"{kbs_value:.0f}KB/s"
    
    # Build stats text
    stats_parts = []
    
    # CPU - show user and sys separately
    cpu_total = cpu_user + cpu_sys
    stats_parts.append(("󰻠 ", get_color(cpu_total), f"{cpu_user:.1f}%/{cpu_sys:.1f}%"))
    
    # Memory
    stats_parts.append(("  󰍛 ", get_color(mem_percent), f"{mem_percent:.1f}%"))
    
    # Network - icon red if VPN is connected (excluding Tailscale), dimmer white text
    vpn_name = _get_vpn_name()
    network_icon_color = as_rgb(0xff5555) if vpn_name else as_rgb(0xcccccc)  # Red if VPN, dimmer white otherwise
    stats_parts.append(("  󰈀 ", network_icon_color, as_rgb(0xaaaaaa), f"↓{format_network(rx_mb)} ↑{format_network(tx_mb)}"))
    
    # Calculate total length
    total_length = 0
    for item in stats_parts:
        icon = item[0]
        text = item[-1]
        total_length += len(icon) + (len(text) if text else 0)
    
    # Calculate padding
    padding = screen.columns - screen.cursor.x - total_length
    
    if padding > 0:
        # Fill with spaces
        screen.draw(" " * padding)
        
        # Draw each part with appropriate colors
        default_fg = screen.cursor.fg
        for item in stats_parts:
            if len(item) == 4:  # icon, icon_color, text_color, text
                icon, icon_color, text_color, text = item
                screen.cursor.fg = icon_color
                screen.draw(icon)
                if text:
                    screen.cursor.fg = text_color
                    screen.draw(text)
            else:  # icon, color, text (old format for CPU/Memory)
                icon, color, text = item
                if color:
                    screen.cursor.fg = color
                screen.draw(icon)
                if text:
                    screen.draw(text)
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
    
    # Get working directory and process name using TabAccessor
    from kitty.tab_bar import TabAccessor
    import os
    
    ta = TabAccessor(tab.tab_id)
    cwd = ta.active_wd
    # Use oldest foreground process (the command you typed, not subprocesses like ssh)
    process = ta.active_oldest_exe or ta.active_exe or tab.title
    
    # Check if we have a custom title
    boss = get_boss()
    tab_obj = boss.tab_for_id(tab.tab_id)
    if tab_obj and tab_obj.name:
        cwd = None

    # Build custom title with folder and process
    title_text = ""
    if cwd:
        # Shorten home directory
        home = os.path.expanduser('~')
        if cwd.startswith(home):
            cwd = '~' + cwd[len(home):]
        
        # Keep only last directory component if too long
        parts = [p for p in cwd.split('/') if p]
        if len(parts) > 1:
            cwd = parts[-1]
        elif parts:
            cwd = '/'.join(parts)
        
        # Build title without ANSI codes first
        folder_icon = '  '  # Folder icon
        process_icon = '  '  # Terminal/CLI icon
        title_text = f"{folder_icon}{cwd} {process_icon}{process}"
    else:
        title_text = tab.title
    
    # Truncate title if needed
    if len(title_text) > max_title_length:
        title_text = title_text[:max_title_length - 1] + '…'
    
    # Define colors - lighter background with very light foreground
    if tab.is_active:
        bg = 0x3a3a3a  # Medium dark gray for active
        fg = 0xffffff  # White
    else:
        bg = 0x1a1a1a  # Very dark gray for inactive (more dimmed)
        fg = 0x666666  # Darker gray text for inactive
    
    # Powerline separator character - right-pointing chevron only
    right_sep = '\ue0b0'   # Powerline right-pointing chevron
    
    # Tab bar background color - matches inactive tab background
    tab_bar_bg = 0x1a1a1a  # Very dark gray (same as inactive)
    
    # Draw tab background and content
    screen.cursor.bg = as_rgb(bg)
    screen.cursor.fg = as_rgb(fg)
    
    # Add padding and draw title with inline colors
    screen.draw(' ')
    
    if cwd:
        # Adjust colors based on active/inactive state
        if tab.is_active:
            icon_color_rgb = (255, 255, 255)      # Pure white for icons
            folder_color_rgb = (255, 230, 180)    # Very light cream
            process_color_rgb = (210, 255, 210)   # Very light green
        else:
            # Dimmed colors for inactive tabs
            icon_color_rgb = (150, 150, 150)      # Dimmed gray for icons
            folder_color_rgb = (180, 160, 130)    # Dimmed cream
            process_color_rgb = (140, 180, 140)   # Dimmed green
        
        folder_icon = '\uf07c '  # Folder icon from nerd fonts
        
        # Draw in format: <process> <icon> <dir>
        # Draw process name first
        screen.cursor.fg = as_rgb(process_color_rgb[0] << 16 | process_color_rgb[1] << 8 | process_color_rgb[2])
        screen.draw(process)
        
        screen.draw(' ')
        
        # Draw folder icon
        screen.cursor.fg = as_rgb(icon_color_rgb[0] << 16 | icon_color_rgb[1] << 8 | icon_color_rgb[2])
        screen.draw(folder_icon)
        
        # Draw directory name
        screen.cursor.fg = as_rgb(folder_color_rgb[0] << 16 | folder_color_rgb[1] << 8 | folder_color_rgb[2])
        screen.draw(cwd)
    else:
        screen.draw(title_text)
    
    screen.draw(' ')
    
    # Draw right separator
    if is_last:
        # Last tab: transition to pure black tab bar background
        screen.cursor.bg = as_rgb(0x000000)  # Pure black
        screen.cursor.fg = as_rgb(bg)
        screen.draw(right_sep)
        
        # Then draw stats on pure black background
        screen.cursor.bg = as_rgb(0x000000)
        _draw_right_status(screen)
    else:
        # Not last tab: transition to tab bar background (inactive color)
        screen.cursor.bg = as_rgb(tab_bar_bg)
        screen.cursor.fg = as_rgb(bg)
        screen.draw(right_sep)
    
    return screen.cursor.x

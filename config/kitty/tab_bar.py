"""Custom tab bar for Kitty with slanted powerline tabs and system stats"""
import subprocess
from datetime import datetime
from kitty.fast_data_types import Screen, get_options
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_tab_with_powerline,
)
from kitty.utils import color_as_int

opts = get_options()


def _get_cpu_usage():
    """Get CPU usage as (user%, sys%) - cross platform"""
    try:
        import os
        import time
        
        # Cache previous values to calculate delta
        if not hasattr(_get_cpu_usage, 'prev_idle'):
            _get_cpu_usage.prev_idle = 0
            _get_cpu_usage.prev_total = 0
            _get_cpu_usage.last_check = 0
            _get_cpu_usage.cached_value = (0.0, 0.0)
        
        # Only update every 15 seconds
        now = time.time()
        if now - _get_cpu_usage.last_check < 15.0:
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
            # macOS - use top to get CPU usage (need 2 samples)
            result = subprocess.run(
                ["top", "-l", "2", "-n", "0", "-s", "1"],
                capture_output=True,
                text=True,
                timeout=2.5
            )
            # Parse output to get CPU usage from the second sample
            lines = result.stdout.split('\n')
            cpu_line = None
            for line in reversed(lines):
                if 'CPU usage' in line:
                    cpu_line = line
                    break
            
            if cpu_line:
                # Parse "CPU usage: 8.78% user, 7.55% sys, 83.65% idle"
                parts = cpu_line.split(',')
                user = float(parts[0].split(':')[1].strip().replace('%', '').split()[0])
                sys = float(parts[1].strip().replace('%', '').split()[0])
                _get_cpu_usage.cached_value = (user, sys)
                _get_cpu_usage.last_check = now
                return (user, sys)
            return _get_cpu_usage.cached_value
    except Exception:
        return getattr(_get_cpu_usage, 'cached_value', (0.0, 0.0))


def _get_memory_usage():
    """Get memory usage in GB"""
    try:
        import time
        
        # Cache previous values
        if not hasattr(_get_memory_usage, 'cached_value'):
            _get_memory_usage.cached_value = (0.0, 0.0)
            _get_memory_usage.last_check = 0
        
        # Only update every 15 seconds
        now = time.time()
        if now - _get_memory_usage.last_check < 15.0:
            return _get_memory_usage.cached_value
        
        result = subprocess.run(
            ["vm_stat"],
            capture_output=True,
            text=True,
            timeout=0.5
        )
        lines = result.stdout.split('\n')
        
        page_size = 4096
        free = active = inactive = wired = 0
        
        for line in lines:
            if 'page size of' in line:
                page_size = int(line.split()[-2])
            elif 'Pages free' in line:
                free = int(line.split()[-1].rstrip('.'))
            elif 'Pages active' in line:
                active = int(line.split()[-1].rstrip('.'))
            elif 'Pages inactive' in line:
                inactive = int(line.split()[-1].rstrip('.'))
            elif 'Pages wired down' in line:
                wired = int(line.split()[-1].rstrip('.'))
        
        used = (active + wired) * page_size / (1024 ** 3)
        total = (free + active + inactive + wired) * page_size / (1024 ** 3)
        
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
        
        # Cache previous values to calculate rate
        if not hasattr(_get_network_stats, 'prev_rx'):
            _get_network_stats.prev_rx = 0
            _get_network_stats.prev_tx = 0
            _get_network_stats.prev_time = time.time()
            _get_network_stats.rx_rate = 0.0
            _get_network_stats.tx_rate = 0.0
        
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
            # macOS - use netstat
            result = subprocess.run(
                ["netstat", "-ibn"],
                capture_output=True,
                text=True,
                timeout=0.5
            )
            for line in result.stdout.split('\n'):
                parts = line.split()
                if len(parts) >= 10 and parts[0] not in ['lo0', 'Name', 'Ibytes', 'Obytes']:
                    if '<Link#' in line:
                        try:
                            rx_bytes += int(parts[6]) if parts[6].isdigit() else 0
                            tx_bytes += int(parts[9]) if parts[9].isdigit() else 0
                        except (ValueError, IndexError):
                            continue
        
        # Calculate rate (bytes per second)
        current_time = time.time()
        time_delta = current_time - _get_network_stats.prev_time
        
        if time_delta >= 15.0:  # Update every 15 seconds
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
    """Get active VPN connection name - cross platform"""
    try:
        import os
        import time
        
        # Cache VPN status
        if not hasattr(_get_vpn_name, 'cached_value'):
            _get_vpn_name.cached_value = None
            _get_vpn_name.last_check = 0
        
        # Only update every 15 seconds
        now = time.time()
        if now - _get_vpn_name.last_check < 15.0:
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
            # macOS - check for active VPN via scutil
            result = subprocess.run(
                ["scutil", "--nc", "list"],
                capture_output=True,
                text=True,
                timeout=0.5
            )
            for line in result.stdout.split('\n'):
                if '(Connected)' in line:
                    # Parse line like: "* (Connected)       ABCD1234-...  IPSec        "VPN Name""
                    parts = line.split('"')
                    if len(parts) >= 2:
                        vpn_name = parts[1]
                        break
        
        _get_vpn_name.cached_value = vpn_name
        _get_vpn_name.last_check = now
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
    stats_parts.append((" 󰍛 ", get_color(mem_percent), f"{mem_percent:.1f}%"))
    

    # Network
    vpn_name = _get_vpn_name()
    if vpn_name:
        net_text = f"󰈀 ↓{format_network(rx_mb)} ↑{format_network(tx_mb)} 󰖂 {vpn_name} "
    else:
        net_text = f"󰈀 ↓{format_network(rx_mb)} ↑{format_network(tx_mb)} "
    stats_parts.append((net_text, None, None))
    
    # Calculate total length
    total_length = 0
    for icon, _, text in stats_parts:
        total_length += len(icon) + (len(text) if text else 0)
    
    # Calculate padding
    padding = screen.columns - screen.cursor.x - total_length
    
    if padding > 0:
        # Fill with spaces
        screen.draw(" " * padding)
        
        # Draw each part with appropriate colors
        default_fg = screen.cursor.fg
        for icon, color, text in stats_parts:
            if color:
                screen.cursor.fg = color
            screen.draw(icon)
            if text:
                screen.draw(text)
            if color:
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
    """Draw tab using kitty's built-in slanted powerline style"""
    
    # Use kitty's built-in slanted powerline drawing
    draw_tab_with_powerline(
        draw_data, screen, tab, before, max_title_length, index, is_last, extra_data
    )
    
    # Add datetime on the right for the last tab
    if is_last:
        _draw_right_status(screen)
    
    return screen.cursor.x

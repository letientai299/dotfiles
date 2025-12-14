"""Custom tab bar for Kitty with powerline tabs and system stats"""
import subprocess
from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
)
from kitty.utils import color_as_int

# Powerline symbols - sharp edges
RIGHT_SEP = ""  # U+E0B0
LEFT_SEP = ""   # U+E0B2

# Colors - High contrast scheme
ACTIVE_BG = as_rgb(color_as_int(0xc0caf5))  # Light blue for active tab
ACTIVE_FG = as_rgb(color_as_int(0x1a1b26))  # Dark text
INACTIVE_BG = as_rgb(color_as_int(0x414868))  # Gray-blue for inactive
INACTIVE_FG = as_rgb(color_as_int(0xc0caf5))  # Light text
BAR_BG = as_rgb(color_as_int(0x1a1b26))  # Dark bar background
STAT_BG = as_rgb(color_as_int(0x7aa2f7))  # Blue for stats
STAT_FG = as_rgb(color_as_int(0x1a1b26))  # Dark text


def _get_cpu_usage():
    """Get CPU usage percentage"""
    try:
        result = subprocess.run(
            ["ps", "-A", "-o", "%cpu"],
            capture_output=True,
            text=True,
            timeout=0.5
        )
        cpu_values = [float(x) for x in result.stdout.split()[1:] if x.replace('.', '').isdigit()]
        return sum(cpu_values)
    except Exception:
        return 0.0


def _get_memory_usage():
    """Get memory usage in GB"""
    try:
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
        
        return used, total
    except Exception:
        return 0.0, 0.0


def _get_network_stats():
    """Get network stats in MB"""
    try:
        result = subprocess.run(
            ["netstat", "-ib"],
            capture_output=True,
            text=True,
            timeout=0.5
        )
        lines = result.stdout.split('\n')
        
        rx_bytes = 0
        tx_bytes = 0
        
        for line in lines[1:]:
            parts = line.split()
            if len(parts) >= 10 and parts[0] not in ['lo0', 'Name']:
                try:
                    if parts[3] != '<Link#0>':
                        rx_bytes += int(parts[6]) if parts[6].isdigit() else 0
                        tx_bytes += int(parts[9]) if parts[9].isdigit() else 0
                except (ValueError, IndexError):
                    continue
        
        rx_mb = rx_bytes / (1024 ** 2)
        tx_mb = tx_bytes / (1024 ** 2)
        
        return rx_mb, tx_mb
    except Exception:
        return 0.0, 0.0


def _draw_right_status(screen: Screen, draw_data: DrawData):
    """Draw system stats on the right side"""
    cpu = _get_cpu_usage()
    mem_used, mem_total = _get_memory_usage()
    rx_mb, tx_mb = _get_network_stats()
    
    parts = []
    
    # CPU
    cpu_icon = "" if cpu < 50 else "" if cpu < 80 else ""
    parts.append(f" {cpu_icon} {cpu:4.1f}%")
    
    # Memory
    if mem_total > 0:
        parts.append(f" {mem_used:.1f}/{mem_total:.0f}GB")
    else:
        parts.append(f" 0.0/0.0GB")
    
    # Network
    parts.append(f" ↓{rx_mb:5.1f}M ↑{tx_mb:5.1f}M")
    
    stats_content = " │ ".join(parts) + " "
    
    # Calculate fill space
    available = screen.columns - screen.cursor.x - len(stats_content) - 1  # -1 for separator
    if available > 0:
        # Fill with bar background
        screen.cursor.fg = BAR_BG
        screen.cursor.bg = BAR_BG
        screen.draw(" " * available)
        
        # Draw left separator for stats
        screen.cursor.fg = STAT_BG
        screen.cursor.bg = BAR_BG
        screen.draw(LEFT_SEP)
        
        # Draw stats
        screen.cursor.fg = STAT_FG
        screen.cursor.bg = STAT_BG
        screen.draw(stats_content)


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
    """Draw a single tab with powerline style"""
    
    # Determine colors based on active state
    if tab.is_active:
        fg, bg = ACTIVE_FG, ACTIVE_BG
    else:
        fg, bg = INACTIVE_FG, INACTIVE_BG
    
    # Set colors
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    
    # Calculate cells drawn
    min_width = 30
    
    # Start tab content
    tab_content = " "
    
    # Add icon based on index
    icons = ["", "", "", "", "", "", "", "", ""]
    tab_content += icons[index % len(icons)] + " "
    
    # Add activity indicators
    if tab.needs_attention:
        tab_content += " "
    if tab.has_activity:
        tab_content += " "
    
    # Add title
    title = tab.title
    available_space = min_width - len(tab_content) - 2  # -2 for padding and separator
    if len(title) > available_space:
        title = title[:available_space - 1] + "…"
    tab_content += title
    
    # Pad to minimum width
    padding = min_width - len(tab_content) - 2  # -2 for end padding and separator
    if padding > 0:
        tab_content += " " * padding
    
    tab_content += " "
    
    # Draw tab content
    screen.draw(tab_content)
    
    # Draw separator with sharp edge
    if is_last:
        # Transition to bar background
        screen.cursor.fg = bg
        screen.cursor.bg = BAR_BG
        screen.draw(RIGHT_SEP)
        
        # Draw right side stats
        _draw_right_status(screen, draw_data)
    else:
        # Transition to next tab
        next_tab = draw_data.tab_bar_data[index + 1]
        next_bg = ACTIVE_BG if next_tab.is_active else INACTIVE_BG
        screen.cursor.fg = bg
        screen.cursor.bg = next_bg
        screen.draw(RIGHT_SEP)
    
    return screen.cursor.x

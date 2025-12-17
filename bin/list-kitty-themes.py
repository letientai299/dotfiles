import os
import sys
import glob
import zipfile
import json

themes_dir = os.path.expanduser("~/.config/kitty/kitty-themes/themes")
cache_zip = os.path.expanduser("~/Library/Caches/kitty/kitty-themes.zip")

def get_luminance(hex_color):
    hex_color = hex_color.lstrip('#')
    if len(hex_color) == 3:
        hex_color = ''.join([c*2 for c in hex_color])
    try:
        r = int(hex_color[0:2], 16)
        g = int(hex_color[2:4], 16)
        b = int(hex_color[4:6], 16)
        return (0.299 * r + 0.587 * g + 0.114 * b)
    except ValueError:
        return 0

def get_theme_type_from_file(theme_path):
    try:
        with open(theme_path, 'r') as f:
            for line in f:
                if line.strip().startswith('background'):
                    parts = line.split()
                    if len(parts) >= 2:
                        color = parts[1]
                        lum = get_luminance(color)
                        return "Light" if lum > 128 else "Dark"
    except Exception:
        pass
    return "Unknown"

themes = {}

# 1. Load from Cache Zip
if os.path.exists(cache_zip):
    try:
        with zipfile.ZipFile(cache_zip, 'r') as z:
            # Read themes.json
            try:
                with z.open('kitty-themes-master/themes.json') as f:
                    data = json.load(f)
                    for entry in data:
                        # entry['file'] is like "themes/Name.conf"
                        filename = os.path.basename(entry.get('file', ''))
                        if filename.endswith('.conf'):
                            name = filename[:-5]
                            is_dark = entry.get('is_dark', False)
                            themes[name] = "Dark" if is_dark else "Light"
            except KeyError:
                pass
    except Exception:
        pass

# 2. Load from Local Directory (overrides cache if same name, or adds new ones)
if os.path.exists(themes_dir):
    for theme_file in glob.glob(os.path.join(themes_dir, "*.conf")):
        name = os.path.basename(theme_file).replace(".conf", "")
        # If not already in list (or we want to re-check local files to be sure),
        # but trusting the cache for known themes is faster.
        # However, local file might differ from cache.
        # Let's check type only if not in cache to save time, 
        # or if we want to be strictly correct about local file content, we should check.
        # Given the user wants "more themes", the cache is the priority for quantity.
        if name not in themes:
            themes[name] = get_theme_type_from_file(theme_file)

# Print sorted
for name in sorted(themes.keys()):
    print(f"{themes[name]:<8} {name}")

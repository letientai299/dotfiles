import subprocess
import json

cmd = ['kitty', '@', 'ls']
result = subprocess.run(cmd, capture_output=True, text=True)
print(result.stdout)

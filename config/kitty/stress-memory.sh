#!/usr/bin/env bash
set -euo pipefail

CHUNK_MB="${1:-64}"
SLEEP_SEC="${2:-0.2}"

python3 - "$CHUNK_MB" "$SLEEP_SEC" <<'PY'
import signal
import sys
import time

chunk_mb = int(sys.argv[1])
sleep_sec = float(sys.argv[2])
chunks = []
running = True

def stop(*_):
    global running
    running = False

signal.signal(signal.SIGINT, stop)
signal.signal(signal.SIGTERM, stop)

print(f"Allocating {chunk_mb}MB every {sleep_sec}s. Press Ctrl-C to stop.")
while running:
    chunks.append(bytearray(chunk_mb * 1024 * 1024))
    allocated_mb = len(chunks) * chunk_mb
    print(f"allocated: {allocated_mb}MB", flush=True)
    time.sleep(sleep_sec)

print("Stopping and releasing memory...")
chunks.clear()
PY

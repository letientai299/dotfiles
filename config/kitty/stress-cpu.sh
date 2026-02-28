#!/usr/bin/env bash
set -euo pipefail

get_cores() {
  if command -v sysctl >/dev/null 2>&1; then
    sysctl -n hw.logicalcpu 2>/dev/null && return
  fi
  if command -v nproc >/dev/null 2>&1; then
    nproc && return
  fi
  getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1
}

CORES="${1:-$(get_cores)}"
PIDS=()

cleanup() {
  for pid in "${PIDS[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
}

trap cleanup EXIT INT TERM

echo "Starting ${CORES} busy workers. Press Ctrl-C to stop."
for _ in $(seq 1 "$CORES"); do
  while :; do :; done &
  PIDS+=("$!")
done

wait

#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-both}" # download | upload | both
DOWNLOAD_URL="${2:-https://speed.hetzner.de/100MB.bin}"
UPLOAD_URL="${3:-https://httpbin.org/post}"
UPLOAD_MB="${UPLOAD_MB:-16}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required"
  exit 1
fi

case "$MODE" in
  download|upload|both) ;;
  *)
    echo "Usage: $0 [download|upload|both] [download_url] [upload_url]"
    exit 1
    ;;
esac

PIDS=()
UPLOAD_FILE=""

cleanup() {
  for pid in "${PIDS[@]:-}"; do
    kill "$pid" 2>/dev/null || true
  done
  if [[ -n "$UPLOAD_FILE" && -f "$UPLOAD_FILE" ]]; then
    rm -f "$UPLOAD_FILE"
  fi
}

download_worker() {
  while :; do
    curl --location --silent --show-error --output /dev/null "$DOWNLOAD_URL" || true
  done
}

upload_worker() {
  UPLOAD_FILE="$(mktemp)"
  dd if=/dev/zero of="$UPLOAD_FILE" bs=1048576 count="$UPLOAD_MB" status=none
  while :; do
    curl --silent --show-error --output /dev/null --request POST --data-binary @"$UPLOAD_FILE" "$UPLOAD_URL" || true
  done
}

trap cleanup EXIT INT TERM

echo "Starting network stress: mode=$MODE (Ctrl-C to stop)"
echo "download URL: $DOWNLOAD_URL"
echo "upload URL:   $UPLOAD_URL (payload ${UPLOAD_MB}MB)"

if [[ "$MODE" == "download" || "$MODE" == "both" ]]; then
  download_worker &
  PIDS+=("$!")
fi

if [[ "$MODE" == "upload" || "$MODE" == "both" ]]; then
  upload_worker &
  PIDS+=("$!")
fi

wait

#!/usr/bin/env bash
set -euo pipefail

steps=(
  "Galaxy Trivia|https://github.com/ParanoidUser/yolo/discussions/categories/galaxy-trivia?discussions_q=category%3A%22Galaxy+Trivia%22+is%3Aunanswered+is%3Aopen"
  "YOLO badge|https://github.com/ParanoidUser/yolo/discussions/18"
  "Starstruck|https://github.com/ParanoidUser/yolo/discussions/385"
  "Pair Extraordinaire|https://github.com/ParanoidUser/yolo/discussions/26"
  "Mysterious badges|https://github.com/ParanoidUser/yolo/discussions/30"
)

open_links=false
if [[ "${1:-}" == "--open" ]]; then
  open_links=true
fi

opener=""
if $open_links; then
  if command -v xdg-open >/dev/null 2>&1; then
    opener="xdg-open"
  elif command -v open >/dev/null 2>&1; then
    opener="open"
  else
    echo "No link opener found. Install xdg-open (Linux) or use macOS 'open'." >&2
    exit 1
  fi
fi

echo "Running the \"Where to start?\" steps:"

for i in "${!steps[@]}"; do
  name="${steps[$i]%%|*}"
  url="${steps[$i]#*|}"
  printf '%d. %s\n   %s\n' "$((i + 1))" "$name" "$url"
  if [[ -n "$opener" ]]; then
    "$opener" "$url" >/dev/null 2>&1 &
    sleep 0.5
  fi
done

if [[ -n "$opener" ]]; then
  echo "Opened all links in your default browser."
else
  echo "Tip: run './scripts/setup.sh --open' to open all links automatically."
fi

#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readme_path="$repo_root/docs/README.md"

# Delay between link-open requests, in seconds, to avoid overwhelming browser/tab handlers.
browser_open_delay_seconds=0.5

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
    echo "No supported link opener found. This script supports xdg-open (Linux) and open (macOS)." >&2
    exit 1
  fi
fi

if [[ ! -f "$readme_path" ]]; then
  echo "README not found at: $readme_path" >&2
  exit 1
fi

mapfile -t steps < <(awk '
  # Parse links from the "Where to start?" section in docs/README.md.
  /^## Where to start\?/ { in_section=1; next }
  in_section && /^## / { in_section=0 }
  in_section && /^- / {
    if (match($0, /\[([^]]+)\]\((https?:\/\/[^)]+)\)/, found)) {
      print found[1] "|" found[2]
    }
  }
' "$readme_path")

if [[ ${#steps[@]} -eq 0 ]]; then
  echo "No getting-started links found in $readme_path" >&2
  exit 1
fi

echo "Displaying the \"Where to start?\" steps:"

for i in "${!steps[@]}"; do
  name="${steps[$i]%%|*}"
  url="${steps[$i]#*|}"
  printf '%d. %s\n   %s\n' "$((i + 1))" "$name" "$url"
  if [[ -n "$opener" ]]; then
    "$opener" "$url" >/dev/null 2>&1 &
    sleep "$browser_open_delay_seconds"
  fi
done

if [[ -n "$opener" ]]; then
  echo "Opened all links in your default browser."
else
  echo "Tip: run './scripts/setup.sh --open' to open all links automatically."
fi

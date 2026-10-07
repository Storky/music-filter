#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

read -rp "Folder name to search: " name
if [[ -z "$name" ]]; then
  echo "Nothing entered. Bye." >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    source "$PROJECT_ROOT/lib/search-macos.sh"
    search_fn=search_macos
    ;;
  MINGW*|MSYS*|CYGWIN*)
    source "$PROJECT_ROOT/lib/search-windows.sh"
    search_fn=search_windows
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

source "$PROJECT_ROOT/lib/log.sh"
# ...after case/uname block:
log_init
log_event "query:    $name"
log_event ""

matches=()
while IFS= read -r line; do
  case "$line" in
    "SCAN "*)
      rest="${line#SCAN }"
      path="${rest% *}"
      result="${rest##* }"
      log_scan "$path" "$result"
      ;;
    "MATCH "*)
      matches+=("${line#MATCH }")
      ;;
    *)
      echo "$line" >&2
      ;;
  esac
done < <("$search_fn" "$name" 2>&1)

echo
if [[ ${#matches[@]} -eq 0 ]]; then
  echo "No folders found matching: $name"
else
  echo "Found ${#matches[@]}:"
  for m in "${matches[@]}"; do
    echo "  $m"
  done
fi

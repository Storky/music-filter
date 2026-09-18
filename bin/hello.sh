#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

read -rp "Folder name to search: " name
if [[ -z "$name" ]]; then
  echo "Nothing entered. Bye." >&2
  exit 1
fi

case "$(uname -s)" in
  Darwin)
    source "$PROJECT_ROOT/lib/search-macos.sh"
    mapfile_cmd=search_macos
    ;;
  MINGW*|MSYS*|CYGWIN*)
    source "$PROJECT_ROOT/lib/search-windows.sh"
    mapfile_cmd=search_windows
    ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

matches=()
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  matches+=("$line")
done < <("$mapfile_cmd" "$name")

echo
if [[ ${#matches[@]} -eq 0 ]]; then
  echo "No folders found matching: $name"
else
  echo "Found ${#matches[@]}:"
  for m in "${matches[@]}"; do
    echo "  $m"
  done
fi

#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

read -rp "Folder name to search: " name

if [[ -z "$name" ]]; then
  echo "Nothing entered. Bye." >&2
  exit 1
fi

root="$HOME/Documents"
echo "Searching in: $root"
echo

matches=()

while IFS= read -r dir; do
  echo "  scanning: $dir" >&2
  if [[ "$(basename "$dir")" == *"$name"* ]]; then
    matches+=("$dir")
  fi
done < <(find "$root" -maxdepth 2 -type d 2>/dev/null)

echo
if [[ ${#matches[@]} -eq 0 ]]; then
  echo "No folders found matching: $name"
else
  echo "Found ${#matches[@]}:"
  for m in "${matches[@]}"; do
    echo "  $m"
  done
fi


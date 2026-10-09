#!/usr/bin/env bash
# search_macos <name>
# Prints matching folder paths (one per line) to stdout.
# Progress goes to stderr.

search_macos() {
  shopt -s nocasematch
  local name="$1"
  local root="$HOME/Documents"

  echo "Searching in: $root" >&2
  echo >&2

  while IFS= read -r dir; do
    if [[ "$(basename "$dir")" == *"$name"* ]]; then
      echo "SCAN $dir success"
      echo "MATCH $dir"
    else
      echo "SCAN $dir null"
    fi
  done < <(find "$root" -maxdepth 2 -type d 2>/dev/null)
}

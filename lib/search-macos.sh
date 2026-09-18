#!/usr/bin/env bash
# search_macos <name>
# Prints matching folder paths (one per line) to stdout.
# Progress goes to stderr.

search_macos() {
  local name="$1"
  local root="$HOME/Documents"

  echo "Searching in: $root" >&2
  echo >&2

  find "$root" -maxdepth 2 -type d 2>/dev/null \
    | while IFS= read -r dir; do
        echo "  scanning: $dir" >&2
        if [[ "$(basename "$dir")" == *"$name"* ]]; then
          echo "$dir"
        fi
      done
}

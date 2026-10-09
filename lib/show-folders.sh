#!/usr/bin/env bash
# show-folders.sh
# Public: show_folders [path...]
#   If no args, reads paths from stdin (one per line).
#   stdout: prints stored folders.

SHOW_FOLDERS=()

show_folders() {
  SHOW_FOLDERS=()

  if [[ $# -gt 0 ]]; then
    SHOW_FOLDERS=("$@")
  else
    while IFS= read -r line; do
      [[ -n "$line" ]] && SHOW_FOLDERS+=("$line")
    done
  fi

  if [[ ${#SHOW_FOLDERS[@]} -eq 0 ]]; then
    echo "No folders to show." >&2
    return 1
  fi

  for f in "${SHOW_FOLDERS[@]}"; do
    echo "$f"
  done
}

#!/usr/bin/env bash
# folders-pick.sh
# Public: folders_pick
#   Opens a native folder picker (macOS: AppleScript).
#   stdout: chosen path
#   stderr: notes on cancel

folders_pick() {
  local path
  path="$(osascript -e 'POSIX path of (choose folder with prompt "Pick a folder")' 2>/dev/null)"

  if [[ -z "$path" ]]; then
    echo "No folder picked." >&2
    return 1
  fi

  # osascript appends a trailing slash; strip it
  echo "${path%/}"
}

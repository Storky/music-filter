#!/usr/bin/env bash
# search_windows <name>
# Prints matching folder paths (one per line) to stdout.
# Progress goes to stderr.

search_windows() {
  local name="$1"

  local script_dir project_root
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  project_root="$(cd "$script_dir/.." && pwd)"

  local es_exe="$project_root/assets/apps/es.exe"
  local everything_exe="$project_root/assets/apps/everything.exe"

  if [[ ! -f "$es_exe" ]]; then
    echo "es.exe not found at: $es_exe" >&2
    return 1
  fi

  local root_win
  if command -v cygpath >/dev/null 2>&1; then
    root_win="$(cygpath -m "$HOME/Documents")"
  else
    root_win="$HOME/Documents"
  fi

  echo "Searching in: $root_win" >&2
  echo >&2

  if ! tasklist 2>/dev/null | grep -qi "everything.exe"; then
    echo "Starting Everything in background..." >&2
    "$everything_exe" -startup >/dev/null 2>&1 &
    sleep 2
  fi

  MSYS_NO_PATHCONV=1 "$es_exe" /ad -path "$root_win" "$name"
}

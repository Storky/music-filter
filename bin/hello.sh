#!/usr/bin/env bash
set -euo pipefail
shopt -s nocasematch

# --- detect OS ---
case "$(uname -s)" in
  Darwin)               OS=macos ;;
  MINGW*|MSYS*|CYGWIN*) OS=windows ;;
  *)                    OS=unknown ;;
esac

# --- project paths ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- input ---
read -rp "Folder name to search: " name
if [[ -z "$name" ]]; then
  echo "Nothing entered. Bye." >&2
  exit 1
fi

matches=()

if [[ "$OS" == "windows" ]]; then
  ES_EXE="$PROJECT_ROOT/assets/apps/es.exe"
  EVERYTHING_EXE="$PROJECT_ROOT/assets/apps/everything.exe"

  if [[ ! -f "$ES_EXE" ]]; then
    echo "es.exe not found at: $ES_EXE" >&2
    exit 1
  fi

  # Everything stores paths as C:\..., so convert /c/Users/... -> C:\Users\...
  root_win="$HOME/Documents"
  if command -v cygpath >/dev/null 2>&1; then
    root_win="$(cygpath -w "$HOME/Documents")"
  fi

  echo "Searching in: $root_win"
  echo

  # start Everything if it's not running (best effort)
  if ! tasklist 2>/dev/null | grep -qi "everything.exe"; then
    echo "Starting Everything in background..." >&2
    "$EVERYTHING_EXE" -startup >/dev/null 2>&1 &
    sleep 2
  fi

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    matches+=("$line")
  done < <("$ES_EXE" -folders -path "$root_win" "$name")

else
  # macOS / generic unix
  root="$HOME/Documents"
  echo "Searching in: $root"
  echo

  while IFS= read -r dir; do
    echo "  scanning: $dir" >&2
    if [[ "$(basename "$dir")" == *"$name"* ]]; then
      matches+=("$dir")
    fi
  done < <(find "$root" -maxdepth 2 -type d 2>/dev/null)
fi

# --- report ---
echo
if [[ ${#matches[@]} -eq 0 ]]; then
  echo "No folders found matching: $name"
else
  echo "Found ${#matches[@]}:"
  for m in "${matches[@]}"; do
    echo "  $m"
  done
fi

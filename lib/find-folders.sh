#!/usr/bin/env bash
# find-folders.sh
# Public: find_folders [name]
#   If no name given, prompts for one.
#   stdout: matched folder paths, one per line
#   stderr: progress notes
#   side effect: writes run log via lib/log.sh

find_folders() {
  local name="${1:-}"

  if [[ -z "$name" ]]; then
    read -rp "Folder name to search: " name
  fi

  if [[ -z "$name" ]]; then
    echo "Nothing entered. Bye." >&2
    return 1
  fi

  local project_root
  project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

  local search_fn
  case "$(uname -s)" in
    Darwin)
      source "$project_root/lib/platforms/search-macos.sh"
      search_fn=search_macos
      ;;
    MINGW*|MSYS*|CYGWIN*)
      source "$project_root/lib/platforms/search-windows.sh"
      search_fn=search_windows
      ;;
    *)
      echo "Unsupported OS: $(uname -s)" >&2
      return 1
      ;;
  esac

  log_init
  log_event "query:    $name"
  log_event ""

  local matches=()
  while IFS= read -r line; do
    case "$line" in
      "SCAN "*)
        rest="${line#SCAN }"
        log_scan "${rest% *}" "${rest##* }"
        ;;
      "MATCH "*)
        matches+=("${line#MATCH }")
        ;;
      *)
        echo "$line" >&2
        ;;
    esac
  done < <("$search_fn" "$name" 2>&1)

  log_summary

  echo
  if [[ ${#matches[@]} -eq 0 ]]; then
    echo "No folders found matching: $name"
  else
    echo "Found ${#matches[@]}:"
    for m in "${matches[@]}"; do
      echo "  $m"
    done
  fi
}

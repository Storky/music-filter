#!/usr/bin/env bash
# folder-create.sh
# Public: folder_create_ui [prompt]
#   Opens native macOS dialog, creates result subfolders, returns chosen path.

folder_create_ui() {
  local prompt="${1:-Pick or create a folder for filtering results}"

  log_module_start "folder-create.sh"

  echo
  echo "Creating/picking output folder:"

  local path
  path="$(osascript -e "POSIX path of (choose folder with prompt \"$prompt\")" 2>/dev/null)" || true

  if [[ -z "$path" ]]; then
    echo "Skipped." >&2
    log_event "skipped"
    log_module_end
    return 1
  fi

  path="${path%/}"

  if [[ ! -d "$path" ]]; then
    mkdir -p "$path" || {
      echo "Failed to create: $path" >&2
      log_event "failed: $path"
      log_module_end
      return 1
    }
  fi

  local sub
  for sub in mergedSource mergedFiltered assumablyDeleted; do
    mkdir -p "$path/$sub" || {
      echo "Failed to create: $path/$sub" >&2
      log_event "failed: $path/$sub"
      log_module_end
      return 1
    }
    log_event "  created: $path/$sub"
  done

  echo "  created/picked: $path"
  log_event "created/picked: $path"
  log_module_end

  echo "$path"
}

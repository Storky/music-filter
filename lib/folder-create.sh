#!/usr/bin/env bash
# folder-create.sh
# Public: folder_create_ui [prompt]
#   Opens native macOS dialog, creates the result folder + 3 subfolders.
#   stdout: 4 lines — root, mergedSource, mergedFiltered, assumablyDeleted

folder_create_ui() {
  local prompt="${1:-Pick or create a folder for filtering results}"

  log_module_start "folder-create.sh"

  local path
  path="$(osascript -e "POSIX path of (choose folder with prompt \"$prompt\")" 2>/dev/null)" || true

  if [[ -z "$path" ]]; then
    log_event "skipped"
    log_module_end
    return 1
  fi

  path="${path%/}"

  mkdir -p "$path" || {
    log_event "failed: $path"
    log_module_end
    return 1
  }

  local sub
  for sub in mergedSource mergedFiltered assumablyDeleted; do
    mkdir -p "$path/$sub" || {
      log_event "failed: $path/$sub"
      log_module_end
      return 1
    }
    log_event "  created: $path/$sub"
  done

  log_module_end

  echo "$path"
  echo "$path/mergedSource"
  echo "$path/mergedFiltered"
  echo "$path/assumablyDeleted"
}

#!/usr/bin/env bash
# folder-manager.sh

SLOT_SRC1="/Users/user/Documents/MusicFilteringTestData/Device1/Source"
SLOT_FILTERED1="/Users/user/Documents/MusicFilteringTestData/Device1/Filtered"
SLOT_SRC2="/Users/user/Documents/MusicFilteringTestData/Device2/Source"
SLOT_FILTERED2="/Users/user/Documents/MusicFilteringTestData/Device2/Filtered"

show_folders() {
  log_module_start "folder-manager.sh"

  local any=0

  [[ -n "$SLOT_SRC1"      ]] && { echo "src1:      $SLOT_SRC1";      log_event "src1:      $SLOT_SRC1";      log_listing "$SLOT_SRC1";      any=1; }
  [[ -n "$SLOT_FILTERED1" ]] && { echo "filtered1: $SLOT_FILTERED1"; log_event "filtered1: $SLOT_FILTERED1"; log_listing "$SLOT_FILTERED1"; any=1; }
  [[ -n "$SLOT_SRC2"      ]] && { echo "src2:      $SLOT_SRC2";      log_event "src2:      $SLOT_SRC2";      log_listing "$SLOT_SRC2";      any=1; }
  [[ -n "$SLOT_FILTERED2" ]] && { echo "filtered2: $SLOT_FILTERED2"; log_event "filtered2: $SLOT_FILTERED2"; log_listing "$SLOT_FILTERED2"; any=1; }

  if [[ $any -eq 0 ]]; then
    echo "No folders recorded." >&2
    log_event "(no folders recorded)"
    log_module_end
    return 1
  fi

  log_module_end
}

log_listing() {
  local dir="$1"

  if [[ ! -d "$dir" ]]; then
    log_event "  (missing: $dir)"
    return 0
  fi

  log_event "  contents:"
  local entry
  while IFS= read -r entry; do
    log_event "    $entry"
  done < <(ls -1 "$dir" 2>/dev/null)
}

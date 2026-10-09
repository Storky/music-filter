#!/usr/bin/env bash
# folder-manager.sh

SLOT_SRC1="/Users/user/Documents/MusicFilteringTestData/Device1/Source"
SLOT_FILTERED1="/Users/user/Documents/MusicFilteringTestData/Device1/Filtered"
SLOT_SRC2="/Users/user/Documents/MusicFilteringTestData/Device2/Source"
SLOT_FILTERED2="/Users/user/Documents/MusicFilteringTestData/Device2/Filtered"

RESULT_ROOT=""
MERGED_SOURCE=""
MERGED_FILTERED=""
ASSUMABLY_DELETED=""

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



merge_devices() {
  log_module_start "folder-manager.sh"

  echo "Picking result folder:"
  set_result_folders || { log_module_end; return 1; }

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

  filter_combine_filtered

  log_module_end
}

set_picked_folders() {
  log_module_start "folder-manager.sh"

  SLOT_SRC1="$(folder_pick_one "src1")"           || { log_module_end; return 1; }
  SLOT_FILTERED1="$(folder_pick_one "filtered1")" || { log_module_end; return 1; }
  SLOT_SRC2="$(folder_pick_one "src2")"           || { log_module_end; return 1; }
  SLOT_FILTERED2="$(folder_pick_one "filtered2")" || { log_module_end; return 1; }

  log_event "src1:      $SLOT_SRC1"
  log_event "filtered1: $SLOT_FILTERED1"
  log_event "src2:      $SLOT_SRC2"
  log_event "filtered2: $SLOT_FILTERED2"

  log_module_end
}

set_result_folders() {
  local out
  out="$(folder_create_ui)" || return 1

  RESULT_ROOT="$(echo "$out" | sed -n '1p')"
  MERGED_SOURCE="$(echo "$out" | sed -n '2p')"
  MERGED_FILTERED="$(echo "$out" | sed -n '3p')"
  ASSUMABLY_DELETED="$(echo "$out" | sed -n '4p')"

  log_event "RESULT_ROOT:      $RESULT_ROOT"
  log_event "MERGED_SOURCE:    $MERGED_SOURCE"
  log_event "MERGED_FILTERED:  $MERGED_FILTERED"
  log_event "ASSUMABLY_DELETED: $ASSUMABLY_DELETED"
}

filter_combine_filtered() {
  if [[ -z "$MERGED_FILTERED" ]]; then
    echo "filter_combine_filtered: MERGED_FILTERED not set" >&2
    log_event "filter_combine_filtered: MERGED_FILTERED not set"
    return 1
  fi

  mkdir -p "$MERGED_FILTERED"

  local src
  for src in "$SLOT_FILTERED1" "$SLOT_FILTERED2"; do
    if [[ -z "$src" || ! -d "$src" ]]; then
      log_event "skip (missing): $src"
      continue
    fi

    log_event "merging: $src -> $MERGED_FILTERED"

    local entry
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      cp -R "$src/$entry" "$MERGED_FILTERED/" && log_event "  copied: $entry"
    done < <(ls -1 "$src" 2>/dev/null)
  done
}

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
  echo "set_result_folders"

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
    echo "filter_combine_filtered"

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

filter_combine_source() {
  if [[ -z "$MERGED_SOURCE" ]]; then
    echo "filter_combine_source: MERGED_SOURCE not set" >&2
    log_event "filter_combine_source: MERGED_SOURCE not set"
    return 1
  fi

  mkdir -p "$MERGED_SOURCE"

  local src
  for src in "$SLOT_SRC1" "$SLOT_SRC2"; do
    if [[ -z "$src" || ! -d "$src" ]]; then
      log_event "skip (missing): $src"
      continue
    fi

    log_event "merging: $src -> $MERGED_SOURCE"

    local entry
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      cp -R "$src/$entry" "$MERGED_SOURCE/" && log_event "  copied: $entry"
    done < <(ls -1 "$src" 2>/dev/null)
  done
}

filter_assume_deleted() {
  if [[ -z "$ASSUMABLY_DELETED" ]]; then
    echo "filter_assume_deleted: ASSUMABLY_DELETED not set" >&2
    log_event "filter_assume_deleted: ASSUMABLY_DELETED not set"
    return 1
  fi

  mkdir -p "$ASSUMABLY_DELETED"

  local src1_list src2_list only_in_1 only_in_2 candidates entry

  src1_list="$(ls -1 "$SLOT_SRC1" 2>/dev/null)"
  src2_list="$(ls -1 "$SLOT_SRC2" 2>/dev/null)"

  only_in_1="$(comm -23 <(echo "$src1_list" | sort) <(echo "$src2_list" | sort))"
  only_in_2="$(comm -13 <(echo "$src1_list" | sort) <(echo "$src2_list" | sort))"

  candidates="$(printf '%s\n%s\n' "$only_in_1" "$only_in_2" | sed '/^$/d' | sort -u)"

  log_event "candidates (in exactly one source):"
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    log_event "  $entry"
  done <<< "$candidates"

  log_event "excluding entries present in mergedFiltered"

  local filtered_list
  filtered_list="$(ls -1 "$MERGED_FILTERED" 2>/dev/null | sort)"

  local final_list
  final_list="$(comm -23 <(echo "$candidates" | sort) <(echo "$filtered_list"))"

  log_event "final (assumably deleted):"
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    log_event "  $entry"

    local from_src=""
    [[ -d "$SLOT_SRC1/$entry" ]] && from_src="$SLOT_SRC1/$entry"
    [[ -d "$SLOT_SRC2/$entry" ]] && from_src="$SLOT_SRC2/$entry"

    if [[ -n "$from_src" ]]; then
      cp -R "$from_src" "$ASSUMABLY_DELETED/" && log_event "    copied from: $from_src"
    fi
  done <<< "$final_list"

  log_event "removing assumably-deleted entries from mergedSource"
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if [[ -d "$MERGED_SOURCE/$entry" ]]; then
      rm -rf "$MERGED_SOURCE/$entry" && log_event "  removed from mergedSource: $entry"
    fi
  done <<< "$final_list"
}

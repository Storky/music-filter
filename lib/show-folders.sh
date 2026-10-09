#!/usr/bin/env bash
# show-folders.sh
# Public:
#   set_folder <slot> <path>   — record a folder into a slot
#   show_folders               — print all recorded slots
# Slots: src1, filtered1, src2, filtered2

SLOT_SRC1=""
SLOT_FILTERED1=""
SLOT_SRC2=""
SLOT_FILTERED2=""

set_folder() {
  local slot="$1"
  local path="$2"

  case "$slot" in
    src1)      SLOT_SRC1="$path" ;;
    filtered1) SLOT_FILTERED1="$path" ;;
    src2)      SLOT_SRC2="$path" ;;
    filtered2) SLOT_FILTERED2="$path" ;;
    *)
      echo "set_folder: unknown slot '$slot'" >&2
      return 1
      ;;
  esac
}

show_folders() {
  local any=0

  [[ -n "$SLOT_SRC1"      ]] && { echo "src1:      $SLOT_SRC1";      any=1; }
  [[ -n "$SLOT_FILTERED1" ]] && { echo "filtered1: $SLOT_FILTERED1"; any=1; }
  [[ -n "$SLOT_SRC2"      ]] && { echo "src2:      $SLOT_SRC2";      any=1; }
  [[ -n "$SLOT_FILTERED2" ]] && { echo "filtered2: $SLOT_FILTERED2"; any=1; }

  if [[ $any -eq 0 ]]; then
    echo "No folders recorded." >&2
    return 1
  fi
}

#!/usr/bin/env bash
# merger.sh

merge_devices() {
  log_module_start "merger.sh"

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

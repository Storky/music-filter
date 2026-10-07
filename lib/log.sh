#!/usr/bin/env bash
# lib/log.sh
# Shared logger for app.sh.
# Writes a per-run log file under $PROJECT_ROOT/logs/.
#
# Contract:
#   log_init            — must be called once before any log_* call.
#   log_line <msg>      — append one raw line to the log.
#   log_scan <path> <result>  — append "SCAN <path> <result>".
#   log_event <msg>     — append a plain event line (no prefix).
#   log_summary         — append the trailing summary block.
#
# Assumes $PROJECT_ROOT is already set by the caller.

# Internal state (set by log_init)
LOG_FILE=""
LOG_SCANNED=0
LOG_MAX_DEPTH=0
LOG_FOUND=()

log_init() {
  if [[ -z "${PROJECT_ROOT:-}" ]]; then
    echo "log_init: PROJECT_ROOT is not set" >&2
    return 1
  fi

  local dir="$PROJECT_ROOT/logs"
  mkdir -p "$dir"

  local ts
  ts="$(date '+%a-%-d-%b_%H-%M-%S_%Y')"
  LOG_FILE="$dir/run-${ts}.log"

  # header
  {
    echo "=== run $(date '+%a %-d %b, %H:%M:%S, %Y') ==="
    echo "os:       $(uname -s)"
  } >> "$LOG_FILE"

  # reset accumulators
  LOG_SCANNED=0
  LOG_MAX_DEPTH=0
  LOG_FOUND=()
}

log_line() {
  [[ -z "$LOG_FILE" ]] && return 0
  echo "$*" >> "$LOG_FILE"
}

log_event() {
  log_line "$*"
}

# log_scan <path> <result>
# result is "null" or "success"
log_scan() {
  local path="$1"
  local result="$2"

  local tag
  if [[ "$result" == "success" ]]; then
    tag="SUCCESS"
  else
    tag="null"
  fi
  log_line "$tag $path"
  LOG_SCANNED=$(( LOG_SCANNED + 1 ))


  # track max depth relative to $HOME/Documents (best-effort)
  local root="${HOME}/Documents"
  local rel="${path#"$root"/}"
  if [[ "$rel" != "$path" ]]; then
    local depth
    depth=$(awk -F'/' '{print NF}' <<< "$rel")
    (( depth > LOG_MAX_DEPTH )) && LOG_MAX_DEPTH=$depth
  fi

  if [[ "$result" == "success" ]]; then
    LOG_FOUND+=("$path")
  fi
}

log_summary() {
  log_line ""
  log_line "--- summary ---"
  log_line "scanned:  $LOG_SCANNED"
  log_line "max depth: $LOG_MAX_DEPTH"
  log_line "found:    ${#LOG_FOUND[@]}"
  for f in "${LOG_FOUND[@]}"; do
    log_line "  $f"
  done
  log_line "=== end $(date '+%Y-%m-%d %H:%M:%S') ==="
}

log_path() {
  echo "$LOG_FILE"
}

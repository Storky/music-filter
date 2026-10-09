#!/usr/bin/env bash
# folders-pick.sh
# Public: folders_pick

folders_pick() {
  log_module_start "folders-pick.sh"

  local slots=(src1 filtered1 src2 filtered2)
  local slot path prompt

  for slot in "${slots[@]}"; do
    prompt="Pick $slot folder:"
    echo "$prompt" >&2

    path="$(osascript -e "POSIX path of (choose folder with prompt \"$prompt\")" 2>/dev/null)" || true

    if [[ -z "$path" ]]; then
      log_event "cancelled at slot: $slot"
      echo "No folder picked for $slot." >&2
      log_module_end
      return 1
    fi

    path="${path%/}"
    echo "  recorded $slot: $path" >&2
    log_event "picked $slot: $path"
    set_folder "$slot" "$path"
  done

  log_module_end
}

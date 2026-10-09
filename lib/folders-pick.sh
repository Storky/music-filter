#!/usr/bin/env bash
# folders-pick.sh
# Public: folders_pick
#   Opens native folder pickers for src1, filtered1, src2, filtered2.
#   Records each into the slot globals from show-folders.sh.

folders_pick() {
  local slots=(src1 filtered1 src2 filtered2)
  local slot path prompt

  for slot in "${slots[@]}"; do
    prompt="Pick $slot folder:"
    echo "$prompt" >&2

    path="$(osascript -e "POSIX path of (choose folder with prompt \"$prompt\")" 2>/dev/null)" || true

    if [[ -z "$path" ]]; then
      echo "No folder picked for $slot." >&2
      return 1
    fi

    path="${path%/}"
    echo "  recorded $slot: $path" >&2
    set_folder "$slot" "$path"
  done
}

#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_ROOT/lib/log.sh"
source "$PROJECT_ROOT/lib/folders-pick.sh"

log_init

chosen="$(folders_pick)"

echo
echo "Picked: $chosen"

echo
echo "(log: $(log_path))"

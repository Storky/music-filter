#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$PROJECT_ROOT/lib/log.sh"
source "$PROJECT_ROOT/lib/folder-manager.sh"
#source "$PROJECT_ROOT/lib/folders-pick.sh"

log_init

# folders_pick disabled for mocks
# folders_pick

echo "Showing:"
show_folders

echo
echo "(log: $(log_path))"

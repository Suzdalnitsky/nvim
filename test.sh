#!/usr/bin/env bash
# Run the test suite in a bare Neovim (no user config, no plugins but plenary).
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

nvim --headless --noplugin -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"

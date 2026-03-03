#!/bin/bash

# Scenario: persist a single file path (relative to $HOME)
# Verifies the symlink and volume backing are set up correctly.

set -e

source dev-container-features-test-lib

check "symlink exists for settings.json" test -L "$HOME/.config/test-persist/settings.json"
check "symlink target is on volume" readlink -f "$HOME/.config/test-persist/settings.json" | grep -q "^/dc/persist/"
check "volume backing file exists" test -f /dc/persist/home__vscode__.config__test-persist__settings.json

reportResults

#!/bin/bash

# Scenario: persist multiple paths (a file and a directory)
# Verifies both symlinks and their volume backing are created.

set -e

source dev-container-features-test-lib

# File symlink
check "symlink exists for settings.json" test -L "$HOME/.config/test-persist/settings.json"
check "volume backing file exists" test -f /dc/persist/home__vscode__.config__test-persist__settings.json

# Directory symlink (trailing slash in config signals directory)
check "symlink exists for test-data dir" test -L "$HOME/.local/share/test-data"
check "volume backing dir exists" test -d /dc/persist/home__vscode__.local__share__test-data

reportResults

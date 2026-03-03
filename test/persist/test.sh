#!/bin/bash

# This test runs with default options (empty paths).
# It verifies the feature installs without error and the oncreate script exists.

set -e

source dev-container-features-test-lib

check "install.sh created feature dir" test -d /usr/local/share/devcontainer-features/persist
check "oncreate script exists" test -f /usr/local/share/devcontainer-features/persist/scripts/oncreate.sh
check "oncreate script is executable" test -x /usr/local/share/devcontainer-features/persist/scripts/oncreate.sh
check "paths file was written" test -f /usr/local/share/devcontainer-features/persist/paths

reportResults

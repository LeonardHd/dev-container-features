#!/bin/sh
set -e

FEATURE_DIR="/usr/local/share/devcontainer-features/persist"
LIFECYCLE_SCRIPTS_DIR="$FEATURE_DIR/scripts"

echo "Activating feature 'persist'"
echo "User: ${_REMOTE_USER}     User home: ${_REMOTE_USER_HOME}"

if [ -z "$_REMOTE_USER" ] || [ -z "$_REMOTE_USER_HOME" ]; then
    echo "***********************************************************************************"
    echo "*** Require _REMOTE_USER and _REMOTE_USER_HOME to be set (by dev container CLI) ***"
    echo "***********************************************************************************"
    exit 1
fi

mkdir -p "${FEATURE_DIR}"

# The dev container CLI converts a JSON array option to a comma-separated
# string (JS Array.toString()).  Store it as-is for oncreate.sh.
echo "${PATHS}" > "$FEATURE_DIR/paths"
echo "${_REMOTE_USER}" > "$FEATURE_DIR/remote_user"
echo "${_REMOTE_USER_HOME}" > "$FEATURE_DIR/remote_user_home"

# Copy lifecycle script
if [ -f oncreate.sh ]; then
    mkdir -p "${LIFECYCLE_SCRIPTS_DIR}"
    cp oncreate.sh "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
    chmod +x "${LIFECYCLE_SCRIPTS_DIR}/oncreate.sh"
fi

# Make feature dir writable by the remote user so oncreate.sh can write logs
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${FEATURE_DIR}"

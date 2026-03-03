#!/usr/bin/env bash
set -e

FEATURE_DIR="/usr/local/share/devcontainer-features/persist"
VOLUME_DIR="/dc/persist"
LOG_FILE="$FEATURE_DIR/log.txt"

log() {
    echo "$1"
    echo "$1" >> "$LOG_FILE"
}

fix_permissions() {
    local dir="$1"
    if [ ! -w "${dir}" ]; then
        sudo chown -R "$(id -u):$(id -g)" "${dir}"
    fi
}

# Ensure feature dir is writable (install.sh runs as root)
fix_permissions "$FEATURE_DIR"

# Read stored config
PATHS_CSV="$(cat "$FEATURE_DIR/paths")"
REMOTE_USER="$(cat "$FEATURE_DIR/remote_user")"
REMOTE_USER_HOME="$(cat "$FEATURE_DIR/remote_user_home")"

echo "" > "$LOG_FILE"

log "persist oncreate: starting"
log "User: ${REMOTE_USER}     Home: ${REMOTE_USER_HOME}"
log "Paths: ${PATHS_CSV}"

# Fix volume permissions
fix_permissions "$VOLUME_DIR"

# Parse the comma-separated list of paths produced by the dev container CLI
# when the user provides a JSON array in devcontainer.json.
parse_paths() {
    local csv="$1"
    [ -z "$csv" ] && return
    echo "$csv" | tr ',' '\n' | sed 's/^ *//;s/ *$//' | grep -v '^$'
}

persist_path() {
    local raw_path="$1"

    # Resolve relative paths against $HOME
    local full_path
    if [ "${raw_path#/}" = "$raw_path" ]; then
        full_path="${REMOTE_USER_HOME}/${raw_path}"
    else
        full_path="$raw_path"
    fi

    # Determine if this is a file or directory.
    # A trailing slash signals a directory; otherwise check the filesystem.
    local is_dir=false
    if [ "${full_path%/}" != "$full_path" ]; then
        is_dir=true
        full_path="${full_path%/}"
    elif [ -e "$full_path" ] && [ ! -L "$full_path" ] && [ -d "$full_path" ]; then
        is_dir=true
    fi

    # Derive a safe volume sub-path by replacing / with __
    local safe_name
    safe_name="$(echo "$full_path" | sed 's|^/||; s|/|__|g')"
    local vol_path="${VOLUME_DIR}/${safe_name}"

    log "Persisting: ${full_path} -> ${vol_path} (dir=${is_dir})"

    # If the path is already a symlink to the right place, skip
    if [ -L "$full_path" ]; then
        local existing_target
        existing_target="$(readlink -f "$full_path")"
        if [ "$existing_target" = "$(readlink -f "$vol_path")" ]; then
            log "  Already symlinked correctly, skipping"
            return
        fi
    fi

    # Ensure parent dirs exist on both sides
    mkdir -p "$(dirname "$full_path")"
    mkdir -p "$(dirname "$vol_path")"

    if [ "$is_dir" = true ]; then
        # Directory persistence
        mkdir -p "$vol_path"
        if [ -d "$full_path" ] && [ ! -L "$full_path" ]; then
            if [ "$(ls -A "$full_path" 2>/dev/null)" ]; then
                cp -rn "$full_path/." "$vol_path/" 2>/dev/null || true
            fi
            rm -rf "$full_path"
        fi
        ln -sf "$vol_path" "$full_path"
    else
        # File persistence
        mkdir -p "$(dirname "$vol_path")"
        if [ -e "$full_path" ] && [ ! -L "$full_path" ]; then
            if [ ! -e "$vol_path" ]; then
                cp -p "$full_path" "$vol_path"
            fi
            rm -f "$full_path"
        fi
        if [ ! -e "$vol_path" ]; then
            touch "$vol_path"
        fi
        ln -sf "$vol_path" "$full_path"
    fi

    # Fix ownership of the symlink
    chown -h "${REMOTE_USER}:${REMOTE_USER}" "$full_path"

    log "  Done"
}

# Parse and process each path
parse_paths "$PATHS_CSV" | while IFS= read -r p; do
    if [ -n "$p" ]; then
        persist_path "$p"
    fi
done

log "persist oncreate: complete"

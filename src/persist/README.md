# Persist Paths

Persist any number of files or directories across dev container rebuilds. Uses a single Docker named volume scoped to the dev container, with symlinks from the original paths into the volume.

## Usage

```jsonc
{
    "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
    "features": {
        "ghcr.io/<owner>/dev-container-features/persist:0": {
            "paths": [".config/gh/hosts.yml", ".ssh/known_hosts", ".azure"]
        }
    }
}
```

## How it works

1. A Docker volume `${devcontainerId}-persist` is mounted at `/dc/persist`.
2. At install time (`install.sh`), the configured paths and an `oncreate.sh` lifecycle script are saved.
3. At container creation (`onCreateCommand`), each configured path is:
   - Resolved (relative paths are resolved against `$HOME`, absolute paths are used as-is)
   - Backed by a file/directory on the volume at `/dc/persist/<safe-name>`
   - Symlinked from the original location to the volume
   - If the original file/directory already existed, its contents are copied into the volume first (preserving data from the image)

## Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `paths` | array | `[]` | JSON array of paths to persist. Paths without a leading `/` are relative to `$HOME`. |

## Examples

Persist GitHub CLI auth and SSH known hosts:

```jsonc
{
    "features": {
        "ghcr.io/<owner>/dev-container-features/persist:0": {
            "paths": [".config/gh/hosts.yml", ".ssh/known_hosts"]
        }
    }
}
```

Persist an entire directory (e.g. Azure CLI state):

```jsonc
{
    "features": {
        "ghcr.io/<owner>/dev-container-features/persist:0": {
            "paths": [".azure"]
        }
    }
}
```

Mix relative and absolute paths:

```jsonc
{
    "features": {
        "ghcr.io/<owner>/dev-container-features/persist:0": {
            "paths": [".config/gh/hosts.yml", "/etc/some-config.conf"]
        }
    }
}
```

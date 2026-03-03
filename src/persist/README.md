
# Persist Paths (persist)

Persist arbitrary files and directories across dev container rebuilds using a Docker volume.

## Example Usage

```json
"features": {
    "ghcr.io/LeonardHd/dev-container-features/persist:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| paths | JSON array of paths to persist, e.g. [".config/gh/hosts.yml", ".ssh/known_hosts", ".azure"]. Paths without a leading '/' are relative to $HOME. | string | - |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/LeonardHd/dev-container-features/blob/main/src/persist/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

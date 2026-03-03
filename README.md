# Dev Container Features

Custom [dev container Features](https://containers.dev/implementors/features/) hosted on GitHub Container Registry.

## Features

| Feature | Description |
|---------|-------------|
| [persist](src/persist/README.md) | Persist arbitrary files and directories across dev container rebuilds using a Docker volume |

## Repo Structure

```
├── src
│   └── persist
│       ├── devcontainer-feature.json
│       ├── install.sh
│       └── oncreate.sh
├── test
│   └── persist
│       ├── test.sh
│       ├── scenarios.json
│       └── persist_file.sh
```

## Publishing

Features are published to GHCR via the [release workflow](.github/workflows/release.yaml). Each feature is individually versioned in its `devcontainer-feature.json`.

To mark packages as public (required for free tier), navigate to the package settings in GHCR and set visibility to public.

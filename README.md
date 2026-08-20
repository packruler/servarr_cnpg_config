# Servarr CNPG Config Updater

This is a simple container that updates the config files for Radarr, Sonarr, Lidarr, and Readarr to use the secret values from CloudNative Postgres (CNPG) instead of the hardcoded values in the config files.

## What it sets

The container reads a CloudNativePG connection secret mounted at
`/run/secrets/cnpg` and writes these elements into `/config/config.xml`:

| Element | Secret key |
|---|---|
| `PostgresPassword` | `password` |
| `PostgresUser` | `username` |
| `PostgresHost` | `host` |
| `PostgresPort` | `port` |
| `PostgresMainDb` | `dbname` |
| `PostgresLogDb` | `logdb`, or `<dbname>_log` when that key is absent |

An element whose secret key is missing is left as-is.

### The log database

CNPG provisions a single database per cluster and names it in `dbname`.
Servarr needs a second one for logs and, when `<PostgresLogDb>` is absent,
falls back to a compiled-in default (`radarr-log`, `sonarr-log`, ...). That
default is identical for every instance of an app, so several servarr apps
sharing one Postgres cluster would all target the same log database.

Set a `logdb` key on the secret to name it explicitly. Otherwise it is
derived as `<dbname>_log`, which is distinct as long as `dbname` is.

Neither database is created here. Servarr connects with the role from the
secret, which does not need `CREATEDB` -- provision both databases up front.

### Missing elements

Elements are created when absent, not only updated. Servarr reads these
values with `persist: false` and never writes them back, so a config.xml
that has not been pre-seeded has no element to update -- an update-only
edit would silently leave the app on its defaults.

## Configuration

| Variable | Default | Effect |
|---|---|---|
| `SECRET_PATH` | `/run/secrets/cnpg` | Directory holding the mounted secret |
| `CONFIG_PATH` | `/config/config.xml` | Config file to rewrite |
| `VERBOSE` | unset | Print the config before and after |
| `DRY_RUN` | unset | Compute the result but do not write it |

## Docker Image

The Docker image is automatically built and published to GitHub Container Registry (ghcr.io) using GitHub Actions.

### Available Tags

- `latest` - Latest build from the main/master branch
- `v*` - Semantic version tags (e.g., `v1.0.0`, `v1.0`, `v1`)
- Branch names - Builds from specific branches
- PR numbers - Builds from pull requests (for testing)

### Usage

```bash
docker pull ghcr.io/packruler/servarr_cnpg_config:latest
```

## GitHub Actions Workflows

This repository includes two GitHub Actions workflows:

### 1. Docker Build (`docker-build.yml`)

- **Triggers**: Push to main/master, tags, and pull requests
- **Features**:
  - Multi-architecture builds (linux/amd64, linux/arm64)
  - Automatic tagging based on git refs
  - Pushes to GitHub Container Registry
  - Build caching for faster builds
  - Only pushes on main branch and tags (not PRs)

### 2. Security Scan (`security-scan.yml`)

- **Triggers**: Push, pull requests, and weekly schedule
- **Features**:
  - Dockerfile linting with Hadolint
  - Vulnerability scanning with Trivy
  - Results uploaded to GitHub Security tab
  - Weekly automated scans for ongoing security monitoring

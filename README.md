# Servarr CNPG Config Updater

This is a simple container that updates the config files for Radarr, Sonarr, Lidarr, and Readarr to use the secret values from CloudNative Postgres (CNPG) instead of the hardcoded values in the config files.

## Docker Image

The Docker image is automatically built and published to GitHub Container Registry (ghcr.io) using GitHub Actions.

### Available Tags

- `latest` - Latest build from the main/master branch
- `v*` - Semantic version tags (e.g., `v1.0.0`, `v1.0`, `v1`)
- Branch names - Builds from specific branches
- PR numbers - Builds from pull requests (for testing)

### Usage

```bash
docker pull ghcr.io/[your-username]/servarr_cnpg_config:latest
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

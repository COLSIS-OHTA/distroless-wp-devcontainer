# DevContainer

This fork keeps the original runtime services distroless and adds a dedicated `dev` service for VS Code / Cursor.

## Files

```txt
.devcontainer/
├── devcontainer.json
├── docker-compose.yml
└── Dockerfile
```

## Runtime

The existing root `docker-compose.yml` remains the source of truth for WordPress runtime services:

- php
- wp-cli
- webserver
- database
- phpmyadmin
- mail

The DevContainer connects to the `dev` service only.

## Docker / WP-CLI from inside the DevContainer

The `dev` service does not run WordPress itself. To run `docker compose` or WP-CLI from the integrated terminal:

- Feature: `docker-outside-of-docker` (Docker CLI + host socket)
- Volume: `/var/run/docker.sock`
- Wrapper: `compose-wp` → `docker compose exec wp-cli wp …`

Examples:

```bash
docker compose ps
compose-wp plugin list
compose-wp core version
```

`compose-wp` is a wrapper that runs `.devcontainer/scripts/compose-wp.sh` from the workspace (updates apply after `git pull` without rebuilding the image). After changing scripts, run **Dev Containers: Reopen in Container** or:

```bash
bash .devcontainer/scripts/post-start.sh
```

If you see `permission denied while trying to connect to the docker API at unix:///var/run/docker.sock`:

```bash
bash .devcontainer/scripts/setup-docker-access.sh
```

Then open a **new terminal** (or Rebuild Container). This syncs the `docker` group GID with `/var/run/docker.sock` after `updateRemoteUserUID` runs.

## Node / pnpm / safe-chain

The `dev` image is built from `node:22.22.2-bookworm`.

`pnpm@10.12.1` is installed in `.devcontainer/Dockerfile` during image build.
`safe-chain` is also installed in `.devcontainer/Dockerfile` during image build.
`postCreateCommand` only verifies versions, so DevContainer startup is not responsible for installing pnpm or safe-chain.

## Usage

Open the forked `distroless-wp` repository root in VS Code / Cursor and run:

```txt
Dev Containers: Reopen in Container
```

## Troubleshooting

### Stale `dev` image after Dockerfile / Node version changes

If Cursor or VS Code reports **Failed to run devcontainer command** after upgrading the DevContainer (for example `node24-pnpm` → `node22-pnpm`), an old `distroless-wp-dev:*` image may still be in use.

1. Stop the DevContainer / Codespace.
2. Remove old dev images and rebuild without cache:

```bash
docker image rm distroless-wp-dev:node24-pnpm 2>/dev/null || true
docker compose -f docker-compose.yml -f .devcontainer/docker-compose.yml build --no-cache dev
```

3. Run **Dev Containers: Rebuild Container** (or **Rebuild Container Without Cache**).

On Codespaces, **Codespaces: Rebuild Container** is usually enough; if the error persists, delete the codespace and create a new one.

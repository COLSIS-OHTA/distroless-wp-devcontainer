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

`compose-wp` runs `docker exec` against the running `wp-cli` container (no `docker-compose.yml` path resolution on the host). After changing `.devcontainer/scripts/compose-wp.sh`, run **Dev Containers: Rebuild Container** to refresh `/usr/local/bin/compose-wp`.

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

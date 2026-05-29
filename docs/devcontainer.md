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

## Node / pnpm / safe-chain

The `dev` image is built from `node:24-bookworm`.

`pnpm@10.12.1` is installed in `.devcontainer/Dockerfile` during image build.
`safe-chain` is also installed in `.devcontainer/Dockerfile` during image build.
`postCreateCommand` only verifies versions, so DevContainer startup is not responsible for installing pnpm or safe-chain.

## Usage

Open the forked `distroless-wp` repository root in VS Code / Cursor and run:

```txt
Dev Containers: Reopen in Container
```

## Port forwarding (GitHub Codespaces)

Host ports come from `.env` via `docker-compose.yml` (`HOST_MACHINE_*`). Dev Containers / Codespaces forwarding uses **container ports** in `forwardPorts` (`service:port` syntax), so you do not duplicate port numbers in `devcontainer.json`:

| `forwardPorts` | Container port | Default host port (`.env`) |
| --- | --- | --- |
| `webserver:80` | 80 | `HOST_MACHINE_UNSECURE_HOST_PORT=8080` |
| `webserver:443` | 443 | `HOST_MACHINE_SECURE_HOST_PORT=8443` |
| `phpmyadmin:80` | 80 | `HOST_MACHINE_PMA_PORT=9080` |
| `phpmyadmin:443` | 443 | `HOST_MACHINE_PMA_SECURE_PORT=9443` |
| `mail:8025` | 8025 | `HOST_MACHINE_MAILPIT_PORT=19980` |

- WordPress (HTTP) is set to **public** visibility and opens in the browser when forwarded.
- phpMyAdmin and Mailpit default to **private** (Codespaces account only).

After the container starts, `postStartCommand` prints Codespaces URLs using the **host** ports from `.env`, for example:

```text
https://<codespace-name>-8080.app.github.dev/
```

Change `HOST_MACHINE_*` only in `.env`; `forwardPorts` does not support variable substitution in `devcontainer.json`.

## Troubleshooting (GitHub Codespaces / Dev Containers)

### `failed to load provenance blob from build record`

BuildKit may reference a missing provenance attestation blob in the local cache (often on `database` or other built services).

1. Rebuild after pulling the latest `docker-compose.yml` (builds set `provenance: false` and `sbom: false`).
2. In the Codespace terminal, clear the builder cache and rebuild:

```bash
docker builder prune -af
docker compose build --no-cache database
```

3. Run **Codespaces: Rebuild Container** (or **Dev Containers: Rebuild Container** locally).

If the error persists, rebuild all Compose images without cache:

```bash
docker compose build --no-cache
```

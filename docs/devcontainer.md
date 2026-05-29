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

### `COMPOSE_PROJECT_NAME` を変えてもコンテナ名が `wp-*` のまま

Dev Containers / Codespaces は起動時に `.env` の `COMPOSE_PROJECT_NAME` を読み、`docker compose --project-name …` を付けて起動します。**`.env` を変えただけでは反映されません。**

1. リポジトリ**ルート**の `.env` を編集（`.devcontainer/.env` ではない）:

   ```env
   COMPOSE_PROJECT_NAME=myproject
   ```

2. 古い `wp` スタックを止める（ホストまたは DevContainer 内）:

   ```bash
   docker compose -p wp down
   ```

3. **Dev Containers: Rebuild Container**（できれば Without Cache）

4. 確認:

   ```bash
   docker compose ls
   docker ps --format '{{.Names}}' | head
   ```

`docker-compose.yml` 先頭の `name:` も同じ変数を参照します。`Reopen in Container` だけではプロジェクト名は変わりません。

### `Failed to retrieve the Docker Compose configuration`

Dev Containers runs `docker compose ... config` before startup. Common causes:

1. **Invalid `COMPOSE_PROJECT_NAME`** — must be **lowercase** only (letters, numbers, hyphens, underscores).  
   Invalid: `COLSIS-Thailand-Demo`  
   Valid: `colsis-thailand-demo`

   ```env
   COMPOSE_PROJECT_NAME=colsis-thailand-demo
   ```

2. **Invalid `docker-compose.yml`** — run locally:

   ```bash
   docker compose -f docker-compose.yml -f .devcontainer/docker-compose.yml config
   ```

   Fix any YAML or project name error before Rebuild Container.

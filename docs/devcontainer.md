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

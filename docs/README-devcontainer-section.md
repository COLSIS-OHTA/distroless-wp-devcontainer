## DevContainer

This fork includes DevContainer support for VS Code / Cursor.

The WordPress runtime services remain distroless:

- `php`
- `webserver`
- `wp-cli`

The editor connects to a separate `dev` service built from `node:24-bookworm`.

`pnpm@10.12.1` and `safe-chain` are installed at image build time via `.devcontainer/Dockerfile`, so opening the DevContainer automatically provides Node.js, pnpm, and safe-chain.

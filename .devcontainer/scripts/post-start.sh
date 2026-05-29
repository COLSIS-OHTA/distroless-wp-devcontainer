#!/usr/bin/env bash
# DevContainer post-start: docker socket access + refresh compose-wp in PATH.
set -euo pipefail

root="${DEVCONTAINER_WORKSPACE_FOLDER:-/workspaces/distroless-wp}"
if [ -f "${root}/.devcontainer/scripts/setup-docker-access.sh" ]; then
  bash "${root}/.devcontainer/scripts/setup-docker-access.sh" || true
fi

if [ -f "${root}/.devcontainer/scripts/compose-wp-wrapper.sh" ] && command -v sudo >/dev/null 2>&1; then
  sudo install -m 755 "${root}/.devcontainer/scripts/compose-wp-wrapper.sh" /usr/local/bin/compose-wp
fi

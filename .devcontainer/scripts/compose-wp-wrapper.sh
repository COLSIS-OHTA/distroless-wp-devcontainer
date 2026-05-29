#!/usr/bin/env bash
# Wrapper installed in the image; always runs the workspace copy (git pull updates apply).
set -euo pipefail

resolve_compose_wp_script() {
  local dir="${1:-$PWD}"
  local root

  for root in "${DEVCONTAINER_WORKSPACE_FOLDER:-}" "/workspaces/distroless-wp"; do
    if [ -n "$root" ] && [ -f "$root/.devcontainer/scripts/compose-wp.sh" ]; then
      printf '%s\n' "$root/.devcontainer/scripts/compose-wp.sh"
      return 0
    fi
  done

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/.devcontainer/scripts/compose-wp.sh" ]; then
      printf '%s\n' "$dir/.devcontainer/scripts/compose-wp.sh"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  return 1
}

script="$(resolve_compose_wp_script "$PWD")" || {
  echo "compose-wp: could not find .devcontainer/scripts/compose-wp.sh in the workspace." >&2
  exit 1
}

exec bash "$script" "$@"

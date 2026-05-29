#!/usr/bin/env bash
# Run WP-CLI in the wp-cli service (DevContainer / local Compose).
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$root"

compose=(docker compose -f docker-compose.yml -f .devcontainer/docker-compose.yml)

if [ -t 0 ] && [ -t 1 ]; then
  exec "${compose[@]}" exec wp-cli wp "$@"
fi

exec "${compose[@]}" exec -T wp-cli wp "$@"

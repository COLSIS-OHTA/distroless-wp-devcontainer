#!/usr/bin/env bash
# Run WP-CLI in the running wp-cli service (DevContainer / Codespaces).
set -euo pipefail

find_project_root() {
  local dir="${1:-$PWD}"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/docker-compose.yml" ] && [ -d "$dir/.devcontainer" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

read_compose_project_name() {
  local env_file="$1"
  local value

  [ -f "$env_file" ] || return 0
  value="$(grep -E '^COMPOSE_PROJECT_NAME=' "$env_file" | tail -1 | cut -d= -f2- | tr -d "\"'" || true)"
  [ -n "$value" ] && printf '%s\n' "$value"
}

docker_cli() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
    return
  fi

  if command -v sg >/dev/null 2>&1 && getent group docker >/dev/null 2>&1; then
    sg docker -c "docker $(printf '%q ' "$@")"
    return
  fi

  docker "$@"
}

find_wp_cli_container() {
  local project="$1"
  local container

  container="$(docker_cli ps \
    --filter "label=com.docker.compose.service=wp-cli" \
    --filter "label=com.docker.compose.project=${project}" \
    --format '{{.Names}}' | head -1)"
  if [ -n "$container" ]; then
    printf '%s\n' "$container"
    return 0
  fi

  container="$(docker_cli ps \
    --filter "label=com.docker.compose.service=wp-cli" \
    --format '{{.Names}}' | head -1)"
  [ -n "$container" ] && printf '%s\n' "$container"
}

root="$(find_project_root "$PWD")" || {
  echo "compose-wp: could not find repository root (docker-compose.yml)." >&2
  exit 1
}

project="$(read_compose_project_name "$root/.env" || true)"
project="${project:-wp}"

if ! docker info >/dev/null 2>&1 && ! (command -v sg >/dev/null 2>&1 && getent group docker >/dev/null 2>&1); then
  echo "compose-wp: cannot access Docker (permission denied on /var/run/docker.sock)." >&2
  echo "compose-wp: run: bash .devcontainer/scripts/setup-docker-access.sh" >&2
  echo "compose-wp: then open a new terminal, or Dev Containers: Rebuild Container." >&2
  exit 1
fi

container="$(find_wp_cli_container "$project")" || true
if [ -z "$container" ]; then
  echo "compose-wp: wp-cli container is not running (project: ${project})." >&2
  echo "compose-wp: start services with Dev Containers: Rebuild Container, or run docker compose up -d on the host." >&2
  exit 1
fi

if [ -t 0 ] && [ -t 1 ]; then
  exec docker_cli exec -it "$container" wp "$@"
fi

exec docker_cli exec -i "$container" wp "$@"

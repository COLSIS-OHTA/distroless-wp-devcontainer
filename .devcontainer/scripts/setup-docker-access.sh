#!/usr/bin/env bash
# Align docker group GID with the mounted socket so the node user can run docker CLI.
set -euo pipefail

user="${DEVCONTAINER_USER:-node}"

if [ ! -S /var/run/docker.sock ]; then
  echo "setup-docker-access: /var/run/docker.sock not found; skipping." >&2
  exit 0
fi

if docker info >/dev/null 2>&1; then
  exit 0
fi

if ! command -v sudo >/dev/null 2>&1; then
  echo "setup-docker-access: sudo is required to configure docker group access." >&2
  exit 1
fi

socket_gid="$(stat -c '%g' /var/run/docker.sock)"

if getent group docker >/dev/null 2>&1; then
  current_gid="$(getent group docker | cut -d: -f3)"
  if [ "${current_gid}" != "${socket_gid}" ]; then
    sudo groupmod -o -g "${socket_gid}" docker
  fi
else
  sudo groupadd -g "${socket_gid}" docker
fi

if id -nG "${user}" | tr ' ' '\n' | grep -qx docker; then
  :
else
  sudo usermod -aG docker "${user}"
fi

if docker info >/dev/null 2>&1; then
  exit 0
fi

echo "setup-docker-access: docker group updated for ${user}; open a new terminal if access is still denied." >&2

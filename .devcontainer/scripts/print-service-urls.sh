#!/usr/bin/env bash
set -euo pipefail

http_port="${HOST_MACHINE_UNSECURE_HOST_PORT:-8080}"
https_port="${HOST_MACHINE_SECURE_HOST_PORT:-8443}"
pma_port="${HOST_MACHINE_PMA_PORT:-9080}"
mailpit_port="${HOST_MACHINE_MAILPIT_PORT:-19980}"

echo "DevContainer started. WordPress services are managed by Docker Compose."

if [ -n "${CODESPACE_NAME:-}" ]; then
  domain="${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN:-app.github.dev}"
  echo ""
  echo "GitHub Codespaces forwarded URLs (also in the Ports tab):"
  echo "  WordPress (HTTP):  https://${CODESPACE_NAME}-${http_port}.${domain}/"
  echo "  WordPress (HTTPS): https://${CODESPACE_NAME}-${https_port}.${domain}/"
  echo "  phpMyAdmin:        https://${CODESPACE_NAME}-${pma_port}.${domain}/"
  echo "  Mailpit:           https://${CODESPACE_NAME}-${mailpit_port}.${domain}/"
  echo ""
  echo "Host ports follow HOST_MACHINE_* in .env (forwardPorts uses service:containerPort)."
else
  echo ""
  echo "Local forwarded URLs:"
  echo "  WordPress (HTTP):  http://localhost:${http_port}/"
  echo "  WordPress (HTTPS): https://localhost:${https_port}/"
  echo "  phpMyAdmin:        http://localhost:${pma_port}/"
  echo "  Mailpit:           http://localhost:${mailpit_port}/"
fi

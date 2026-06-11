#!/usr/bin/env bash
set -euo pipefail

SERVICE="nginx-proxy"
LOCAL_DIR="./vhost.d"
REMOTE_DIR="/etc/nginx/vhost.d"

echo "Copying vhost configuration files..."
echo "From: ${LOCAL_DIR}"
echo "To:   ${SERVICE}:${REMOTE_DIR}"

if [ ! -d "$LOCAL_DIR" ]; then
  echo "Error: local directory does not exist: $LOCAL_DIR"
  exit 1
fi

if ! docker compose ps --services --filter "status=running" | grep -qx "$SERVICE"; then
  echo "Error: service is not running: $SERVICE"
  echo "Start it with: docker compose up -d $SERVICE"
  exit 1
fi

for file in "$LOCAL_DIR"/*; do
  if [ -f "$file" ]; then
    filename="$(basename "$file")"

    echo "Copying $filename..."
    docker compose cp "$file" "${SERVICE}:${REMOTE_DIR}/${filename}"
  fi
done

echo "Reloading nginx..."
docker restart nginx-proxy
docker restart nginx-companion-le

echo "Done."

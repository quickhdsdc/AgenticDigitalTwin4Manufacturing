#!/bin/sh
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
command -v docker >/dev/null 2>&1 || { echo 'Install and start Docker first.' >&2; exit 1; }
[ "$(docker info --format '{{.OSType}}')" = linux ] || { echo 'Start the Docker Linux engine.' >&2; exit 1; }
docker compose version >/dev/null
[ -f .env ] || cp .env.example .env
mkdir -p projects imports
value() { awk -F '"' -v key="$1" '$2 == key { print $4 }' release.json; }
image=$(value image)
expected=$(value image_id)
archive=$(value archive)
checksum=$(value archive_sha256)
case "$archive" in ''|*/*|*\\*|..*) echo 'Invalid image archive name.' >&2; exit 1;; esac
if [ "$(docker image inspect "$image" --format '{{.Id}}' 2>/dev/null || true)" != "$expected" ]; then
    [ -f "$archive" ] || { echo 'Extract the complete deployment ZIP from Releases.' >&2; exit 1; }
    if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$archive" | cut -d ' ' -f 1)
    else actual=$(shasum -a 256 "$archive" | cut -d ' ' -f 1); fi
    [ "$actual" = "$checksum" ] || { echo 'Image checksum mismatch; download a fresh release.' >&2; exit 1; }
    docker image load --input "$archive"
    [ "$(docker image inspect "$image" --format '{{.Id}}')" = "$expected" ] || exit 1
fi
docker compose up -d --no-build --pull never --wait --wait-timeout 180
port=${REVIEW_HOST_PORT:-}
if [ -z "$port" ]; then port=$(sed -n 's/^REVIEW_HOST_PORT=//p' .env | head -n 1 | tr -d "\r\"' "); fi
port=${port:-8088}
case "$port" in *[!0-9]*) echo 'Invalid REVIEW_HOST_PORT.' >&2; exit 1;; esac
echo "Review Workbench ready: http://127.0.0.1:$port"

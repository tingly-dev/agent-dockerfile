#!/usr/bin/env bash
# Build & run DeepSeek Harness (dsh) web UI in Docker, with persistent config dir.
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_NAME="${IMAGE_NAME:-dsh}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-dsh}"
HOST_PORT="${HOST_PORT:-3080}"
# npm mirror, override freely, e.g. NPM_REGISTRY=https://registry.npmjs.org
NPM_REGISTRY="${NPM_REGISTRY:-https://registry.npmmirror.com}"
# config dir mounted into the container (persisted config/plugins/sessions)
CONFIG_DIR="${CONFIG_DIR:-$PWD/data/dsh}"

mkdir -p "$CONFIG_DIR"

case "${1:-run}" in
  build)
    docker build --build-arg NPM_REGISTRY="$NPM_REGISTRY" -t "$IMAGE_NAME:$IMAGE_TAG" .
    ;;
  run)
    docker build --build-arg NPM_REGISTRY="$NPM_REGISTRY" -t "$IMAGE_NAME:$IMAGE_TAG" .
    docker run -d --name "$CONTAINER_NAME" \
      -p "$HOST_PORT":3080 \
      -v "$CONFIG_DIR":/data/dsh \
      -e NPM_REGISTRY="$NPM_REGISTRY" \
      --restart unless-stopped \
      "$IMAGE_NAME:$IMAGE_TAG"
    echo "dsh web UI: http://127.0.0.1:$HOST_PORT"
    echo "config dir: $CONFIG_DIR"
    ;;
  stop)
    docker rm -f "$CONTAINER_NAME"
    ;;
  logs)
    docker logs -f "$CONTAINER_NAME"
    ;;
  shell)
    docker exec -it "$CONTAINER_NAME" bash
    ;;
  *)
    echo "Usage: $0 {build|run|stop|logs|shell}"
    echo "Env: IMAGE_NAME IMAGE_TAG CONTAINER_NAME HOST_PORT NPM_REGISTRY CONFIG_DIR"
    exit 1
    ;;
esac

#!/usr/bin/env bash
# Build & run DeepSeek Harness (dsh) web UI in Docker, with persistent config dir.
set -euo pipefail

cd "$(dirname "$0")"

IMAGE_NAME="${IMAGE_NAME:-dsh}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
CONTAINER_NAME="${CONTAINER_NAME:-dsh}"
# npm mirror, override freely, e.g. NPM_REGISTRY=https://registry.npmjs.org
NPM_REGISTRY="${NPM_REGISTRY:-https://registry.npmmirror.com}"
# config dir mounted into the container (persisted config/plugins/sessions)
CONFIG_DIR="${CONFIG_DIR:-$PWD/data/dsh}"
# optional: local plugin source dir for plugin development, mounted into the
# container so you can `dsh plugin --profile <name> add /data/dsh/plugin-src/<pkg>`
# or pnpm-link it from inside the container (see: run.sh shell). Unset by default.
PLUGIN_DIR="${PLUGIN_DIR:-}"

mkdir -p "$CONFIG_DIR"

# extra -v args, appended only when PLUGIN_DIR is set
MOUNT_ARGS=()
if [[ -n "$PLUGIN_DIR" ]]; then
  mkdir -p "$PLUGIN_DIR"
  MOUNT_ARGS+=(-v "$PLUGIN_DIR:/data/dsh/plugin-src")
fi

case "${1:-run}" in
  build)
    docker build --build-arg NPM_REGISTRY="$NPM_REGISTRY" -t "$IMAGE_NAME:$IMAGE_TAG" .
    ;;
  run)
    docker build --build-arg NPM_REGISTRY="$NPM_REGISTRY" -t "$IMAGE_NAME:$IMAGE_TAG" .
    # dsh refuses to bind 0.0.0.0 (RCE risk), so it listens on 127.0.0.1 inside
    # the container; use host network to make that reachable on the host.
    docker run -d --name "$CONTAINER_NAME" \
      --network host \
      -v "$CONFIG_DIR":/data/dsh \
      "${MOUNT_ARGS[@]}" \
      -e NPM_REGISTRY="$NPM_REGISTRY" \
      --restart unless-stopped \
      "$IMAGE_NAME:$IMAGE_TAG"
    echo "dsh web UI: http://127.0.0.1:3080 (host network mode)"
    echo "config dir: $CONFIG_DIR"
    [[ -n "$PLUGIN_DIR" ]] && echo "plugin source dir: $PLUGIN_DIR -> /data/dsh/plugin-src"
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
    echo "Env: IMAGE_NAME IMAGE_TAG CONTAINER_NAME NPM_REGISTRY CONFIG_DIR PLUGIN_DIR"
    exit 1
    ;;
esac

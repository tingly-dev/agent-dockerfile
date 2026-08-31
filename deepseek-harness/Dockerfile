FROM node:22-bookworm-slim

# npm registry: default to npmmirror (China mirror), override via build arg / env
ARG NPM_REGISTRY=https://registry.npmmirror.com
ENV NPM_REGISTRY=${NPM_REGISTRY}

# dev tools for plugin development: git (clone/pull plugin repos), vim (quick
# in-container edits), build-essential (native module compiles via pnpm).
# Small footprint, kept in the same image so one image serves both plain
# usage and plugin dev — no need to maintain a second image.
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends git vim build-essential ca-certificates; \
    rm -rf /var/lib/apt/lists/*

# pnpm: dsh forwards `dsh plugin ...` to pnpm inside the profile dir
RUN --mount=type=cache,target=/root/.npm \
    set -eux; \
    printf 'registry=%s\n' "$NPM_REGISTRY" > /usr/local/etc/npmrc; \
    npm config set registry "$NPM_REGISTRY"; \
    corepack enable; \
    corepack prepare pnpm@latest --activate; \
    pnpm config set registry "$NPM_REGISTRY" --global

# dsh version to install: pin to a resolved version for reproducible builds;
# defaults to "latest" for ad-hoc local builds (CI resolves and pins this).
ARG DSH_VERSION=latest

RUN --mount=type=cache,target=/root/.npm \
    npm install -g "@deepseek-ai/dsh@${DSH_VERSION}"

# dsh home: mount here to persist config/plugins/sessions
ENV DSH_HOME=/data/dsh
ENV HOME=/data/dsh
RUN mkdir -p /data/dsh && chown -R node:node /data/dsh
USER node
WORKDIR /data/dsh

ENV DSH_HOST=127.0.0.1
EXPOSE 3080

# dsh intentionally refuses to bind 0.0.0.0 (RCE risk). Use --network host so
# 127.0.0.1:3080 on the host reaches it; override command for other subcommands.
CMD ["dsh", "web"]

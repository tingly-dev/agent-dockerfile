FROM node:22-bookworm-slim

# npm registry: default to npmmirror (China mirror), override via build arg / env
ARG NPM_REGISTRY=https://registry.npmmirror.com
ENV NPM_REGISTRY=${NPM_REGISTRY}

# dsh version to install: pin to a resolved version for reproducible builds;
# defaults to "latest" for ad-hoc local builds (CI resolves and pins this).
ARG DSH_VERSION=latest

RUN --mount=type=cache,target=/root/.npm \
    set -eux; \
    printf 'registry=%s\n' "$NPM_REGISTRY" > /usr/local/etc/npmrc; \
    npm config set registry "$NPM_REGISTRY"; \
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

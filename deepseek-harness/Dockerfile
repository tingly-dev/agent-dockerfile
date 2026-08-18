# syntax=docker/dockerfile:1
FROM node:22-bookworm-slim

# npm registry: default to npmmirror (China mirror), override via build arg / env
ARG NPM_REGISTRY=https://registry.npmmirror.com
ENV NPM_REGISTRY=${NPM_REGISTRY}

RUN set -eux; \
    printf 'registry=%s\n' "$NPM_REGISTRY" > /usr/local/etc/npmrc; \
    npm config set registry "$NPM_REGISTRY"; \
    npm install -g @deepseek-ai/dsh; \
    npm cache clean --force

# dsh home: mount here to persist config/plugins/sessions
ENV DSH_HOME=/data/dsh
ENV HOME=/data/dsh
RUN mkdir -p /data/dsh && chown -R node:node /data/dsh
USER node
WORKDIR /data/dsh

ENV DSH_HOST=0.0.0.0
EXPOSE 3080

# Web UI; override command for other subcommands (dsh --help)
CMD ["dsh", "web", "--host", "0.0.0.0"]

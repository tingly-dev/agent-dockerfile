# agent-dockerfile

Dockerfiles for running coding agents / agent harnesses, one subdirectory per project.

| 目录 | 内容 |
|---|---|
| [`deepseek-harness/`](./deepseek-harness) | DeepSeek Harness (dsh) Web UI 的 Docker 部署,含 Dockerfile、启动脚本与文档 |

## CI

`.github/workflows/build-dsh.yml` 在 push / PR / 手动触发时自动构建镜像并推送到 GHCR:
`ghcr.io/<owner>/<repo>-dsh`(`latest` + `sha-<commit>`)。npm 源默认 npmmirror,
可在仓库 Variables 里设 `NPM_REGISTRY` 覆盖。

拉取运行:

```bash
docker run -d --name dsh --network host \
  -v "$PWD/data/dsh":/data/dsh ghcr.io/<owner>/<repo>-dsh:latest
```

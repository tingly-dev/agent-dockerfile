# dsh Docker 部署 | dsh in Docker

用 Docker 运行 [DeepSeek Harness (dsh)](https://github.com/deepseek-ai/deepseek-harness) 的 Web UI,配置目录持久化,npm 源默认走国内镜像且可用环境变量切换。

## 文件说明

| 文件 | 作用 |
|---|---|
| `Dockerfile` | 基于 `node:22-bookworm-slim`,全局安装 `@deepseek-ai/dsh`;同时带 git/vim/build-essential/pnpm,一个镜像兼顾日常使用和插件开发 |
| `run.sh` | 构建/启动/停止/看日志/进容器的辅助脚本 |
| `data/dsh/` | 挂载的配置目录(自动创建),容器内路径 `/data/dsh` |

## 快速开始

```bash
chmod +x run.sh
./run.sh run        # 构建镜像并后台启动
# 打开 http://127.0.0.1:3080
```

## npm 镜像源

默认使用 `https://registry.npmmirror.com`(构建时写入 npm 配置)。通过环境变量覆盖:

```bash
# 使用官方源构建
NPM_REGISTRY=https://registry.npmjs.org ./run.sh build
# 构建时也传入运行时环境变量(容器内 dsh 安装插件时同样生效)
NPM_REGISTRY=https://registry.npmjs.org ./run.sh run
```

## 挂载配置目录

配置、插件、会话数据都持久化在 `CONFIG_DIR`(默认 `./data/dsh`)对应容器内 `/data/dsh`(即容器 HOME)。

```bash
# 自定义路径
CONFIG_DIR=/srv/dsh ./run.sh run
```

删除容器后重建,数据仍在。

## 插件开发

镜像里已经装好 git / vim / build-essential / pnpm(`dsh plugin` 子命令会转发给 pnpm),不需要单独一个开发镜像。挂载本地插件源码目录:

```bash
PLUGIN_DIR=~/code/my-dsh-plugin ./run.sh run
```

容器内路径固定为 `/data/dsh/plugin-src`。进容器操作(装依赖、`pnpm link`、跑 `dsh plugin --profile <name> add ...` 等):

```bash
./run.sh shell
```

## 常用命令

```bash
./run.sh build     # 只构建镜像
./run.sh run       # 构建并启动
./run.sh stop      # 删除容器
./run.sh logs      # 跟随日志
./run.sh shell     # 进入容器 shell
```

可调环境变量:`IMAGE_NAME` `IMAGE_TAG` `CONTAINER_NAME` `HOST_PORT` `NPM_REGISTRY` `CONFIG_DIR` `PLUGIN_DIR`。

## 手动 docker 命令

```bash
docker build --build-arg NPM_REGISTRY=https://registry.npmmirror.com -t dsh .
docker run -d --name dsh --network host \
  -v "$PWD/data/dsh":/data/dsh \
  -e NPM_REGISTRY=https://registry.npmmirror.com \
  dsh
```

> dsh 出于安全考虑拒绝绑定 `0.0.0.0`(Web UI 可执行代码,RCE 风险),容器内只监听
> `127.0.0.1:3080`,因此使用 `--network host` 让宿主机可访问。

## 说明

- dsh 处于 developer preview,API 可能随时变更,建议固定镜像 tag。
- Web UI 监听端口 3080,可用 `HOST_PORT` 改宿主机映射。
- 如需其他子命令:`docker exec -it dsh dsh --help`,或改 `Dockerfile` 的 `CMD`。

---
name: cloudflared-tunnel-inspector
description: 在 Linux 设备上检查并列出当前通过 cloudflared tunnel 对外公开的服务（hostname -> 本地 service），并输出对应 tunnel 与配置文件信息。当用户要求“查看 tunnel 暴露服务”“列出 cloudflared 配置”“查看当前公开地址列表”时使用。
allowed-tools: Bash, Read, Grep
related-skills: cloudflared-tunnel, bug-finder, technical-writer
---

# Cloudflared Tunnel 巡检助手

列出当前设备上由 `cloudflared` 暴露的服务和 tunnel 配置，默认以可读列表输出。

## 首选执行方式

优先运行脚本：

```bash
bash scripts/list_exposed_services.sh
```

## 常用参数

- `--config-dir <dir>`：指定 cloudflared 配置目录（默认 `~/.cloudflared`）
- `--format table|tsv`：输出格式（默认 `table`）
- `--services-only`：仅输出对外服务列表，不输出 tunnel 汇总
- `--help`：查看帮助

## 输出内容

### Exposed Services

逐条列出公网入口与本地服务映射，包括：

- hostname
- service
- tunnel name / tunnel id
- connections / created 时间（若可从 `cloudflared tunnel list` 获取）
- config file
- credentials file

### Domain Naming Warnings

输出疑似“临时域名命名”风险项，当前重点标记：

- 子域名含日期后缀（如 `todo-harbor-20260225.example.com`）
- 子域名含长数字时间戳后缀（如 `service-1738493021.example.com`）

建议将这类入口迁移为稳定、简短、长期可复用的子域名（如 `todo.example.com`）。

### Tunnel Summary

按 tunnel 汇总：

- tunnel name / id
- created 时间
- 当前连接信息
- 本地配置中发现的公开服务数量
- 关联配置文件

## 推荐巡检步骤

1. 运行 `bash scripts/list_exposed_services.sh`
2. 确认 hostname 对应 service 是否符合预期
3. 检查 `Domain Naming Warnings` 是否出现日期/时间戳后缀域名
4. 检查是否存在不应暴露的服务端口
5. 对不需要或命名不规范的入口执行清理与迁移（DNS 路由、tunnel 配置、systemd 服务）

## 故障排查

- 脚本未显示连接信息
  - 检查 `cloudflared` 是否安装并可执行
- 只显示部分服务
  - 检查配置目录是否正确，是否存在多份配置文件
- hostname 有但 service 为空
  - 检查对应 `ingress` 规则是否完整

---
name: cloudflared-tunnel
description: 在 Linux 设备上通过 Cloudflare Tunnel（cloudflared）将指定本地服务地址绑定到用户提供的域名，实现快速公网访问。当用户要求“cloudflared tunnel”“内网穿透”“把 localhost 绑定域名”“公网访问本地服务”时使用。
allowed-tools: Bash, Read, Write, Edit, Grep
related-skills: bug-finder, security-audit, technical-writer
---

# Cloudflared Tunnel 助手

在当前 Linux 设备上创建或更新 named tunnel，把 `本地服务地址` 暴露到 `指定域名`。

## 必要输入

- 本地服务地址（必须带协议），例如 `http://127.0.0.1:3000`
- 域名（已接入 Cloudflare DNS），例如 `app.example.com`
- tunnel 名称（可选；未提供时根据域名自动生成）

## 先决条件检查

1. 确认系统是 Linux。
2. 确认已安装 `cloudflared`：`cloudflared --version`
3. 确认已登录 Cloudflare：存在 `~/.cloudflared/cert.pem`
4. 确认本地服务可访问：`curl -I http://127.0.0.1:3000`
5. 确认目标域名在当前 Cloudflare 账号可管理范围内。

若缺少 `cert.pem`，先执行：

```bash
cloudflared tunnel login
```

## 首选执行方式（脚本）

优先在该 skill 目录下运行 `scripts/create_or_update_tunnel.sh`：

```bash
bash scripts/create_or_update_tunnel.sh \
  --domain app.example.com \
  --service http://127.0.0.1:3000 \
  --tunnel-name local-app
```

常用可选参数：

- `--config-dir <dir>`：配置文件输出目录（默认 `~/.cloudflared`）
- `--overwrite-dns`：域名已有 DNS 记录时强制覆盖
- `--run-now`：创建完成后立即前台启动 tunnel
- `--help`：查看完整帮助

## systemd 常驻化（推荐）

创建/更新 tunnel 成功后，必须优先配置 systemd 常驻服务，避免终端退出导致 tunnel 中断。

使用脚本安装服务：

```bash
bash scripts/install_systemd_service.sh \
  --tunnel-name local-app \
  --start-now
```

可选参数：

- `--config-file <path>`：显式指定配置文件（默认 `~/.cloudflared/<tunnel>.yml`）
- `--service-name <name>`：自定义 systemd 服务名
- `--run-user <user>`：指定运行用户（默认当前用户）
- `--dry-run`：仅预览将写入的 unit 文件

安装后常用命令：

```bash
# 查看状态
systemctl status cloudflared-local-app.service

# 查看实时日志
journalctl -u cloudflared-local-app.service -f

# 开机自启/重启/停止
systemctl enable cloudflared-local-app.service
systemctl restart cloudflared-local-app.service
systemctl stop cloudflared-local-app.service
```

删除 systemd 服务：

```bash
sudo systemctl disable --now cloudflared-local-app.service
sudo rm -f /etc/systemd/system/cloudflared-local-app.service
sudo systemctl daemon-reload
```

## 手动执行方式（无脚本时）

```bash
# 1) 创建 tunnel（若已存在可跳过）
cloudflared tunnel create local-app

# 2) 把域名路由到 tunnel
cloudflared tunnel route dns local-app app.example.com

# 3) 获取 tunnel ID 并写配置
cloudflared tunnel info local-app
```

配置文件示例（`~/.cloudflared/local-app.yml`）：

```yaml
tunnel: <TUNNEL_ID>
credentials-file: /home/<user>/.cloudflared/<TUNNEL_ID>.json

ingress:
  - hostname: app.example.com
    service: http://127.0.0.1:3000
  - service: http_status:404
```

启动 tunnel：

```bash
cloudflared tunnel --config ~/.cloudflared/local-app.yml run
```

## 验证与回归检查

1. 本机访问：`curl -I http://127.0.0.1:3000`
2. 公网访问：`curl -I https://app.example.com`
3. 查看 tunnel 状态：`cloudflared tunnel list`
4. 查看运行日志：在启动终端中检查是否出现 `Connected to ...`。

## 常见问题处理

- `failed to find cert.pem`
  - 先执行 `cloudflared tunnel login`
- `hostname is not within a zone in your account`
  - 域名未接入当前账号或账号权限不足
- 已有同名 DNS 记录导致路由失败
  - 清理冲突记录后重新执行 `cloudflared tunnel route dns ...`
- `502/504`
  - 本地服务未启动、地址写错，或只监听了错误网卡

## 安全要求

- 不暴露不应公网访问的本地管理端口（如数据库管理后台）。
- 必要时在源服务上加鉴权，不将 tunnel 当作认证机制本身。
- 处理完成后按需删除不再使用的路由与 tunnel：
  - `cloudflared tunnel route dns delete <domain>`
  - `cloudflared tunnel delete <tunnel-name>`

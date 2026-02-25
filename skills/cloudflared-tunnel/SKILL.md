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
  - 注意：`domain` 和 `tunnel-name` 是两个独立概念，不要求同名

## 域名命名规范（强约束）

- 域名用于对外访问，应优先选择“稳定、短、可长期复用”的子域名。
- 不要把临时 tunnel 名称（尤其带日期/流水号）直接当作正式域名。
- 推荐把 tunnel 命名和公网域名解耦：
  - `tunnel-name` 可以偏运维标识（可含日期、环境、批次）
  - `domain` 应偏产品入口（简洁、稳定）
- 子域名推荐模式：
  - `service.example.com`
  - `service-env.example.com`（仅在确实有环境区分时）
- 不推荐模式：
  - `service-20260225.example.com`（日期后缀）
  - `service-<timestamp>.example.com`（时间戳）
  - `service-<random>.example.com`（随机串）
- 示例：
  - 推荐：`https://todo.biglone.tech`
  - 可接受：`https://todo-harbor.biglone.tech`
  - 不推荐：`https://todo-harbor-20260225.biglone.tech`

当用户未明确给出域名时：

1. 先询问希望使用的稳定子域名；
2. 若需要代拟，优先给 1-2 个简洁候选（不含日期/随机串）；
3. 明确告知“域名不会自动等同于 tunnel-name”。

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
  --domain todo.biglone.tech \
  --service http://127.0.0.1:18080 \
  --tunnel-name todo-harbor-20260225
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

## 域名优化与迁移（去掉日期后缀）

如果当前已在使用类似 `todo-harbor-20260225.biglone.tech` 的域名，推荐迁移为稳定域名（如 `todo.biglone.tech`）：

```bash
# 1) 给同一个 tunnel 绑定新的稳定域名
cloudflared tunnel route dns <tunnel-name-or-id> todo.biglone.tech

# 2) 修改配置文件里的 ingress.hostname 为新域名
#   ~/.cloudflared/<tunnel-name>.yml

# 3) 重启常驻服务
sudo systemctl restart cloudflared-<tunnel-name>.service

# 4) 验证新域名
curl -I https://todo.biglone.tech

# 5) 确认稳定后，删除旧域名路由（可选）
cloudflared tunnel route dns delete todo-harbor-20260225.biglone.tech
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

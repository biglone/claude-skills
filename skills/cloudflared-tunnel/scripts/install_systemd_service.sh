#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
为 cloudflared tunnel 安装 systemd 常驻服务。

用法:
  install_systemd_service.sh --tunnel-name <name> [options]

必填参数:
  --tunnel-name <name>         tunnel 名称（用于定位 ~/.cloudflared/<name>.yml）

可选参数:
  --config-file <path>         显式指定 cloudflared 配置文件路径
  --service-name <name>        systemd 服务名，默认 cloudflared-<tunnel-name>
  --run-user <user>            运行服务的 Linux 用户，默认当前用户
  --unit-dir <dir>             unit 目录，默认 /etc/systemd/system
  --start-now                  写入并 enable 后立刻启动服务
  --dry-run                    仅打印将写入的 unit 内容，不实际安装
  -h, --help                   显示帮助

示例:
  install_systemd_service.sh --tunnel-name local-app --start-now
EOF
}

info() {
    echo "[INFO] $*"
}

err() {
    echo "[ERROR] $*" >&2
}

require_cmd() {
    local cmd="$1"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        err "缺少命令: $cmd"
        exit 1
    fi
}

sanitize_service_name() {
    local value="$1"
    printf '%s' "$value" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9_.@-]/-/g'
}

TUNNEL_NAME=""
CONFIG_FILE=""
SERVICE_NAME=""
RUN_USER="${USER}"
UNIT_DIR="/etc/systemd/system"
START_NOW=0
DRY_RUN=0

while [ $# -gt 0 ]; do
    case "$1" in
        --tunnel-name)
            TUNNEL_NAME="${2:-}"
            shift 2
            ;;
        --config-file)
            CONFIG_FILE="${2:-}"
            shift 2
            ;;
        --service-name)
            SERVICE_NAME="${2:-}"
            shift 2
            ;;
        --run-user)
            RUN_USER="${2:-}"
            shift 2
            ;;
        --unit-dir)
            UNIT_DIR="${2:-}"
            shift 2
            ;;
        --start-now)
            START_NOW=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            err "未知参数: $1"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$TUNNEL_NAME" ]; then
    err "必须提供 --tunnel-name"
    usage
    exit 1
fi

if [ -z "$CONFIG_FILE" ]; then
    CONFIG_FILE="${HOME}/.cloudflared/${TUNNEL_NAME}.yml"
fi

if [ -z "$SERVICE_NAME" ]; then
    SERVICE_NAME="cloudflared-${TUNNEL_NAME}"
fi
SERVICE_NAME="$(sanitize_service_name "$SERVICE_NAME")"

if ! id "$RUN_USER" >/dev/null 2>&1; then
    err "系统用户不存在: $RUN_USER"
    exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
    err "配置文件不存在: $CONFIG_FILE"
    err "请先执行 create_or_update_tunnel.sh 生成配置。"
    exit 1
fi

require_cmd cloudflared
require_cmd systemctl
require_cmd install
require_cmd mktemp
require_cmd sed

CLOUDFLARED_BIN="$(command -v cloudflared)"
RUN_GROUP="$(id -gn "$RUN_USER")"
RUN_HOME="$(getent passwd "$RUN_USER" | cut -d: -f6)"

if [ -z "$RUN_HOME" ]; then
    err "无法获取用户 HOME: $RUN_USER"
    exit 1
fi

UNIT_FILE="${UNIT_DIR}/${SERVICE_NAME}.service"
TMP_UNIT="$(mktemp)"

cat >"$TMP_UNIT" <<EOF
[Unit]
Description=Cloudflared Tunnel (${TUNNEL_NAME})
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=${RUN_USER}
Group=${RUN_GROUP}
Environment=HOME=${RUN_HOME}
ExecStart=${CLOUDFLARED_BIN} tunnel --config ${CONFIG_FILE} run
Restart=always
RestartSec=5s
TimeoutStopSec=15s

[Install]
WantedBy=multi-user.target
EOF

if [ "$DRY_RUN" -eq 1 ]; then
    info "dry-run 模式，不写入系统。unit 内容如下："
    cat "$TMP_UNIT"
    rm -f "$TMP_UNIT"
    exit 0
fi

if [ "${EUID}" -eq 0 ]; then
    install -m 0644 "$TMP_UNIT" "$UNIT_FILE"
    systemctl daemon-reload
    systemctl enable "${SERVICE_NAME}.service"
    if [ "$START_NOW" -eq 1 ]; then
        systemctl restart "${SERVICE_NAME}.service"
    fi
else
    require_cmd sudo
    sudo install -m 0644 "$TMP_UNIT" "$UNIT_FILE"
    sudo systemctl daemon-reload
    sudo systemctl enable "${SERVICE_NAME}.service"
    if [ "$START_NOW" -eq 1 ]; then
        sudo systemctl restart "${SERVICE_NAME}.service"
    fi
fi

rm -f "$TMP_UNIT"

info "systemd 服务已安装: ${UNIT_FILE}"
info "查看状态: systemctl status ${SERVICE_NAME}.service"
info "查看日志: journalctl -u ${SERVICE_NAME}.service -f"
info "重启服务: systemctl restart ${SERVICE_NAME}.service"

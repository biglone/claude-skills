#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
创建或更新 cloudflared named tunnel，并将域名绑定到本地服务。

用法:
  create_or_update_tunnel.sh --domain <domain> --service <local-service-url> [options]

必填参数:
  --domain <domain>            需要暴露的域名，例如 app.example.com
  --service <url>              本地服务地址，例如 http://127.0.0.1:3000

可选参数:
  --tunnel-name <name>         Tunnel 名称，默认根据域名自动生成
  --config-dir <dir>           配置文件目录，默认 ~/.cloudflared
  --overwrite-dns              已存在 DNS 记录时强制覆盖
  --run-now                    创建完成后立即前台启动 tunnel
  -h, --help                   显示帮助

示例:
  create_or_update_tunnel.sh \
    --domain app.example.com \
    --service http://127.0.0.1:3000 \
    --tunnel-name local-app
EOF
}

info() {
    echo "[INFO] $*"
}

warn() {
    echo "[WARN] $*" >&2
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

get_tunnel_id_by_name() {
    local tunnel_name="$1"
    cloudflared tunnel list -o json --name "$tunnel_name" \
        | sed -n 's/.*"id": "\([^"]*\)".*/\1/p' \
        | head -n1
}

default_tunnel_name_from_domain() {
    local raw="$1"
    local name
    name="$(printf '%s' "$raw" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g; s/--*/-/g; s/^-//; s/-$//')"
    name="$(printf '%s' "$name" | cut -c1-63)"
    if [ -z "$name" ]; then
        name="local-tunnel"
    fi
    printf '%s' "$name"
}

validate_domain() {
    local domain="$1"
    if ! printf '%s' "$domain" | grep -Eq '^[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'; then
        err "域名格式无效: $domain"
        exit 1
    fi
}

validate_service() {
    local service="$1"
    if ! printf '%s' "$service" | grep -Eq '^[a-zA-Z][a-zA-Z0-9+.-]*://'; then
        err "本地服务地址必须包含协议，例如 http://127.0.0.1:3000"
        exit 1
    fi
}

DOMAIN=""
SERVICE=""
TUNNEL_NAME=""
CONFIG_DIR="${HOME}/.cloudflared"
RUN_NOW=0
OVERWRITE_DNS=0

while [ $# -gt 0 ]; do
    case "$1" in
        --domain)
            DOMAIN="${2:-}"
            shift 2
            ;;
        --service)
            SERVICE="${2:-}"
            shift 2
            ;;
        --tunnel-name)
            TUNNEL_NAME="${2:-}"
            shift 2
            ;;
        --config-dir)
            CONFIG_DIR="${2:-}"
            shift 2
            ;;
        --run-now)
            RUN_NOW=1
            shift
            ;;
        --overwrite-dns)
            OVERWRITE_DNS=1
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

if [ -z "$DOMAIN" ] || [ -z "$SERVICE" ]; then
    err "必须同时提供 --domain 和 --service"
    usage
    exit 1
fi

validate_domain "$DOMAIN"
validate_service "$SERVICE"

if [ -z "$TUNNEL_NAME" ]; then
    TUNNEL_NAME="$(default_tunnel_name_from_domain "$DOMAIN")"
fi

if ! printf '%s' "$TUNNEL_NAME" | grep -Eq '^[a-z0-9-]{1,63}$'; then
    err "tunnel-name 只允许小写字母、数字和连字符，且长度 1-63"
    exit 1
fi

require_cmd cloudflared
require_cmd sed
require_cmd grep

if [ "$(uname -s)" != "Linux" ]; then
    warn "当前系统不是 Linux，脚本继续执行但未针对该系统验证。"
fi

if [ ! -f "${HOME}/.cloudflared/cert.pem" ]; then
    err "未找到 ${HOME}/.cloudflared/cert.pem，请先运行: cloudflared tunnel login"
    exit 1
fi

mkdir -p "$CONFIG_DIR"

if command -v curl >/dev/null 2>&1; then
    if ! curl -sS --max-time 3 -o /dev/null "$SERVICE"; then
        warn "本地服务暂不可访问: $SERVICE（将继续创建 tunnel）"
    fi
fi

ROUTE_FILE="$(mktemp)"
CREATE_FILE="$(mktemp)"
cleanup() {
    rm -f "$ROUTE_FILE" "$CREATE_FILE"
}
trap cleanup EXIT

TUNNEL_ID="$(get_tunnel_id_by_name "$TUNNEL_NAME")"
if [ -n "$TUNNEL_ID" ]; then
    info "复用已有 tunnel: $TUNNEL_NAME"
else
    info "创建 tunnel: $TUNNEL_NAME"
    cloudflared tunnel create "$TUNNEL_NAME" >"$CREATE_FILE" 2>&1
    TUNNEL_ID="$(get_tunnel_id_by_name "$TUNNEL_NAME")"
    if [ -z "$TUNNEL_ID" ]; then
        TUNNEL_ID="$(sed -n 's/.*with id \([a-f0-9-]\{36\}\).*/\1/p' "$CREATE_FILE" | head -n1)"
    fi
fi

if [ -z "$TUNNEL_ID" ]; then
    err "无法解析 tunnel ID，请手动检查: cloudflared tunnel list -o json --name $TUNNEL_NAME"
    exit 1
fi

CREDENTIALS_FILE="${HOME}/.cloudflared/${TUNNEL_ID}.json"
if [ ! -f "$CREDENTIALS_FILE" ]; then
    err "未找到凭据文件: $CREDENTIALS_FILE"
    err "请检查 cloudflared tunnel create 是否执行成功。"
    exit 1
fi

ROUTE_CMD=(cloudflared tunnel route dns)
if [ "$OVERWRITE_DNS" -eq 1 ]; then
    ROUTE_CMD+=(--overwrite-dns)
fi
ROUTE_CMD+=("$TUNNEL_ID" "$DOMAIN")

if "${ROUTE_CMD[@]}" >"$ROUTE_FILE" 2>&1; then
    info "DNS 路由已绑定: $DOMAIN -> $TUNNEL_NAME"
else
    if grep -Eiq 'already exists|already routed|conflict' "$ROUTE_FILE"; then
        warn "DNS 路由可能已存在，继续执行。详情:"
        sed 's/^/[WARN] /' "$ROUTE_FILE" >&2
    else
        err "DNS 路由创建失败:"
        sed 's/^/[ERROR] /' "$ROUTE_FILE" >&2
        exit 1
    fi
fi

CONFIG_FILE="${CONFIG_DIR}/${TUNNEL_NAME}.yml"
cat >"$CONFIG_FILE" <<EOF
tunnel: ${TUNNEL_ID}
credentials-file: ${CREDENTIALS_FILE}

ingress:
  - hostname: ${DOMAIN}
    service: ${SERVICE}
  - service: http_status:404
EOF

info "配置文件已生成: $CONFIG_FILE"
info "可执行命令: cloudflared tunnel --config $CONFIG_FILE run"
info "常驻建议: bash scripts/install_systemd_service.sh --tunnel-name $TUNNEL_NAME --start-now"

if [ "$RUN_NOW" -eq 1 ]; then
    info "开始前台运行 tunnel（按 Ctrl+C 停止）..."
    cloudflared tunnel --config "$CONFIG_FILE" run
fi

#!/usr/bin/env bash
set -euo pipefail

usage() {
    cat <<'EOF'
列出当前设备通过 cloudflared tunnel 对外公开的服务及配置映射。

用法:
  list_exposed_services.sh [options]

可选参数:
  --config-dir <dir>      cloudflared 配置目录，默认 ~/.cloudflared
  --format <table|tsv>    输出格式，默认 table
  --services-only         仅输出公开服务列表，不输出 tunnel 汇总
  -h, --help              显示帮助

示例:
  list_exposed_services.sh
  list_exposed_services.sh --format tsv
  list_exposed_services.sh --config-dir ~/.cloudflared --services-only
EOF
}

info() {
    echo "[INFO] $*" >&2
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

print_block() {
    local title="$1"
    local header="$2"
    local data_file="$3"
    local format="$4"

    echo "=== ${title} ==="
    if [ ! -s "$data_file" ]; then
        echo "(none)"
        return
    fi

    if [ "$format" = "tsv" ]; then
        printf '%s\n' "$header"
        cat "$data_file"
        return
    fi

    if command -v column >/dev/null 2>&1; then
        {
            printf '%s\n' "$header"
            cat "$data_file"
        } | column -ts $'\t'
    else
        warn "未找到 column，降级为 TSV 输出。"
        printf '%s\n' "$header"
        cat "$data_file"
    fi
}

build_tunnel_map() {
    local output_file="$1"
    local raw_file="$2"

    : >"$output_file"
    : >"$raw_file"

    if ! command -v cloudflared >/dev/null 2>&1; then
        warn "未安装 cloudflared，仅解析本地配置文件。"
        return
    fi

    if ! cloudflared tunnel list >"$raw_file" 2>/dev/null; then
        warn "cloudflared tunnel list 执行失败，仅解析本地配置文件。"
        return
    fi

    awk '
        /^[0-9a-fA-F-]{36}[[:space:]]+/ {
            id = $1
            name = $2
            created = $3
            $1 = ""; $2 = ""; $3 = ""
            sub(/^[[:space:]]+/, "", $0)
            connections = $0
            if (connections == "") connections = "-"
            print id "\t" name "\t" created "\t" connections
        }
    ' "$raw_file" >"$output_file"
}

parse_config_file() {
    local config_file="$1"
    awk -v cfg="$config_file" '
        function trim(s) {
            gsub(/^[ \t]+|[ \t]+$/, "", s)
            return s
        }
        BEGIN {
            tunnel = ""
            cred = ""
            host = ""
        }
        {
            line = $0
            sub(/[ \t]+#.*$/, "", line)
        }
        line ~ /^[ \t]*tunnel:[ \t]*/ {
            value = line
            sub(/^[ \t]*tunnel:[ \t]*/, "", value)
            tunnel = trim(value)
            next
        }
        line ~ /^[ \t]*credentials-file:[ \t]*/ {
            value = line
            sub(/^[ \t]*credentials-file:[ \t]*/, "", value)
            cred = trim(value)
            next
        }
        line ~ /^[ \t]*-[ \t]*hostname:[ \t]*/ {
            if (host != "") {
                print cfg "\t" tunnel "\t" cred "\t" host "\t" "-"
            }
            value = line
            sub(/^[ \t]*-[ \t]*hostname:[ \t]*/, "", value)
            host = trim(value)
            next
        }
        line ~ /^[ \t]*hostname:[ \t]*/ {
            if (host != "") {
                print cfg "\t" tunnel "\t" cred "\t" host "\t" "-"
            }
            value = line
            sub(/^[ \t]*hostname:[ \t]*/, "", value)
            host = trim(value)
            next
        }
        line ~ /^[ \t]*service:[ \t]*/ {
            value = line
            sub(/^[ \t]*service:[ \t]*/, "", value)
            svc = trim(value)
            if (host != "") {
                print cfg "\t" tunnel "\t" cred "\t" host "\t" svc
                host = ""
            }
            next
        }
        END {
            if (host != "") {
                print cfg "\t" tunnel "\t" cred "\t" host "\t" "-"
            }
        }
    ' "$config_file"
}

CONFIG_DIR="${HOME}/.cloudflared"
FORMAT="table"
SERVICES_ONLY=0

while [ $# -gt 0 ]; do
    case "$1" in
        --config-dir)
            CONFIG_DIR="${2:-}"
            shift 2
            ;;
        --format)
            FORMAT="${2:-}"
            shift 2
            ;;
        --services-only)
            SERVICES_ONLY=1
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

if [ "$FORMAT" != "table" ] && [ "$FORMAT" != "tsv" ]; then
    err "--format 仅支持 table 或 tsv"
    exit 1
fi

if [ ! -d "$CONFIG_DIR" ]; then
    err "配置目录不存在: $CONFIG_DIR"
    exit 1
fi

require_cmd awk
require_cmd sed
require_cmd grep
require_cmd find
require_cmd sort
require_cmd mktemp

TMP_TUNNEL_MAP="$(mktemp)"
TMP_TUNNEL_RAW="$(mktemp)"
TMP_CONFIG_ROWS="$(mktemp)"
TMP_SERVICES="$(mktemp)"
TMP_SUMMARY="$(mktemp)"
cleanup() {
    rm -f "$TMP_TUNNEL_MAP" "$TMP_TUNNEL_RAW" "$TMP_CONFIG_ROWS" "$TMP_SERVICES" "$TMP_SUMMARY"
}
trap cleanup EXIT

build_tunnel_map "$TMP_TUNNEL_MAP" "$TMP_TUNNEL_RAW"

: >"$TMP_CONFIG_ROWS"
while IFS= read -r cfg; do
    parse_config_file "$cfg" >>"$TMP_CONFIG_ROWS"
done < <(find "$CONFIG_DIR" -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) | sort)

awk -F '\t' '
    NR == FNR {
        id_to_name[$1] = $2
        id_to_created[$1] = $3
        id_to_conn[$1] = $4
        name_to_id[$2] = $1
        next
    }
    {
        cfg = $1
        tref = $2
        cred = $3
        host = $4
        svc = $5

        if (host == "" || host == "-") {
            next
        }
        if (svc == "") svc = "-"
        if (cred == "") cred = "-"
        if (tref == "") tref = "(missing)"

        tunnel_id = tref
        tunnel_name = tref

        if (tref ~ /^[0-9a-fA-F-]{36}$/) {
            if (id_to_name[tref] != "") {
                tunnel_name = id_to_name[tref]
            } else {
                tunnel_name = "(unknown)"
            }
        } else if (name_to_id[tref] != "") {
            tunnel_id = name_to_id[tref]
            tunnel_name = tref
        } else if (tref != "(missing)") {
            tunnel_id = "(unknown)"
        }

        created = "-"
        connections = "-"
        if (id_to_created[tunnel_id] != "") created = id_to_created[tunnel_id]
        if (id_to_conn[tunnel_id] != "") connections = id_to_conn[tunnel_id]

        print host "\t" svc "\t" tunnel_name "\t" tunnel_id "\t" created "\t" connections "\t" cfg "\t" cred
    }
' "$TMP_TUNNEL_MAP" "$TMP_CONFIG_ROWS" | sort -u >"$TMP_SERVICES"

awk -F '\t' '
    NR == FNR {
        tid = $4
        cfg = $7
        if (tid == "" || tid == "-" || tid == "(unknown)" || tid == "(missing)") next
        if (!(tid in svc_count)) svc_count[tid] = 0
        svc_count[tid]++
        if (!(tid in cfg_files)) {
            cfg_files[tid] = cfg
        } else if (index("," cfg_files[tid] ",", "," cfg ",") == 0) {
            cfg_files[tid] = cfg_files[tid] "," cfg
        }
        next
    }
    {
        id = $1
        name = $2
        created = $3
        connections = $4
        service_count = 0
        if (id in svc_count) service_count = svc_count[id]
        cfg = "-"
        if (id in cfg_files) cfg = cfg_files[id]
        print name "\t" id "\t" created "\t" connections "\t" service_count "\t" cfg
    }
' "$TMP_SERVICES" "$TMP_TUNNEL_MAP" >"$TMP_SUMMARY"

SERVICE_HEADER=$'HOSTNAME\tSERVICE\tTUNNEL_NAME\tTUNNEL_ID\tCREATED_AT\tCONNECTIONS\tCONFIG_FILE\tCREDENTIALS_FILE'
SUMMARY_HEADER=$'TUNNEL_NAME\tTUNNEL_ID\tCREATED_AT\tCONNECTIONS\tPUBLIC_SERVICE_COUNT\tCONFIG_FILES'

print_block "Exposed Services" "$SERVICE_HEADER" "$TMP_SERVICES" "$FORMAT"
echo "Total services: $(wc -l < "$TMP_SERVICES" | tr -d ' ')"

if [ "$SERVICES_ONLY" -eq 0 ]; then
    echo
    print_block "Tunnel Summary" "$SUMMARY_HEADER" "$TMP_SUMMARY" "$FORMAT"
    echo "Total tunnels: $(wc -l < "$TMP_SUMMARY" | tr -d ' ')"
fi

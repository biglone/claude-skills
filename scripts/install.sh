#!/bin/bash

# AI Coding Skills 安装脚本
# 支持 Claude Code 和 OpenAI Codex CLI
# 用法: curl -fsSL https://raw.githubusercontent.com/biglone/agent-skills/main/scripts/install.sh | bash

set -euo pipefail

# 配置
REPO_URL="${SKILLS_REPO:-https://github.com/biglone/agent-skills.git}"
SKILLS_REF="${SKILLS_REF:-main}"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
CLAUDE_WORKFLOWS_DIR="$HOME/.claude/workflows"
CODEX_WORKFLOWS_DIR="$HOME/.codex/workflows"
TEMP_DIR=$(mktemp -d)
CLAUDE_INSTALLED_REPORT="$TEMP_DIR/claude-installed-skills.txt"
CODEX_INSTALLED_REPORT="$TEMP_DIR/codex-installed-skills.txt"

# 安装目标 (claude, codex, both)
INSTALL_TARGET="${INSTALL_TARGET:-}"

# 更新模式 (ask, skip, force)
# ask: 询问用户是否更新已存在的 skill
# skip: 跳过已存在的 skill
# force: 强制更新所有 skill (默认)
UPDATE_MODE="${UPDATE_MODE:-force}"
DEBUG="${DEBUG:-0}"
NON_INTERACTIVE="${NON_INTERACTIVE:-0}"             # 1: 禁用交互输入
DRY_RUN="${DRY_RUN:-0}"                             # 1: 仅打印计划，不写入目标目录
CODEX_AUTO_UPDATE_SETUP="${CODEX_AUTO_UPDATE_SETUP:-on}"   # on/off: 是否自动配置 codex 启动前 skills 更新检查
CODEX_AUTO_UPDATE_REPO="${CODEX_AUTO_UPDATE_REPO:-}"       # owner/repo，默认根据 SKILLS_REPO 推断
CODEX_AUTO_UPDATE_BRANCH="${CODEX_AUTO_UPDATE_BRANCH:-$SKILLS_REF}"
CODEX_LOCAL_VERSION_FILE="${HOME}/.codex/.skills_version"
CODEX_AUTO_UPDATE_LOADER="${HOME}/.codex/codex-skills-auto-update.sh"
SKILLS_MANIFEST_FILE=""
WORKFLOWS_MANIFEST_FILE=""
ASK_FALLBACK_WARNED=0

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_debug() {
    if [ "$DEBUG" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

usage() {
    cat <<'EOF'
Usage: install.sh [options]

Options:
  --non-interactive    Disable prompts and use defaults/env values.
  --dry-run            Print planned actions without writing target dirs.
  -h, --help           Show this help message.

Env:
  INSTALL_TARGET       claude | codex | both
  UPDATE_MODE          ask | skip | force
  SKILLS_REPO          Git repository URL
  SKILLS_REF           Branch/tag/commit-ish to install from (default: main)
EOF
}

parse_args() {
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --non-interactive) NON_INTERACTIVE=1 ;;
            --dry-run) DRY_RUN=1 ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                log_error "未知参数: $1"
                usage
                exit 1
                ;;
        esac
        shift
    done
}

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

is_truthy() {
    case "${1:-}" in
        1|true|TRUE|yes|YES|on|ON) return 0 ;;
        *) return 1 ;;
    esac
}

resolve_github_repo_slug() {
    local input="$1"
    local slug=""

    if printf '%s' "$input" | grep -Eq '^https://github\.com/[^/]+/[^/]+(\.git)?$'; then
        slug="$(printf '%s' "$input" | sed -E 's#^https://github\.com/##; s/\.git$//')"
    elif printf '%s' "$input" | grep -Eq '^git@github\.com:[^/]+/[^/]+(\.git)?$'; then
        slug="$(printf '%s' "$input" | sed -E 's#^git@github\.com:##; s/\.git$//')"
    elif printf '%s' "$input" | grep -Eq '^ssh://git@github\.com/[^/]+/[^/]+(\.git)?$'; then
        slug="$(printf '%s' "$input" | sed -E 's#^ssh://git@github\.com/##; s/\.git$//')"
    fi

    printf '%s' "$slug"
}

validate_update_mode() {
    case "$UPDATE_MODE" in
        ask|skip|force) ;;
        *)
            log_error "UPDATE_MODE 无效: $UPDATE_MODE（可选 ask/skip/force）"
            exit 1
            ;;
    esac
}

validate_install_target() {
    case "$INSTALL_TARGET" in
        ""|claude|codex|both) ;;
        *)
            log_error "INSTALL_TARGET 无效: $INSTALL_TARGET（可选 claude/codex/both）"
            exit 1
            ;;
    esac
}

read_manifest_entries() {
    local manifest_file="$1"
    while IFS= read -r line; do
        local item
        item="$(printf '%s' "$line" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
        [ -z "$item" ] && continue
        case "$item" in \#*) continue ;; esac
        printf '%s\n' "$item"
    done < "$manifest_file"
}

set_manifests() {
    SKILLS_MANIFEST_FILE="$TEMP_DIR/skills-repo/scripts/manifest/skills.txt"
    WORKFLOWS_MANIFEST_FILE="$TEMP_DIR/skills-repo/scripts/manifest/workflows.txt"

    if [ ! -f "$SKILLS_MANIFEST_FILE" ]; then
        log_error "skills manifest 不存在: $SKILLS_MANIFEST_FILE"
        exit 1
    fi
    if [ ! -f "$WORKFLOWS_MANIFEST_FILE" ]; then
        log_warn "workflows manifest 不存在: $WORKFLOWS_MANIFEST_FILE"
    fi
}

upsert_shell_source_block() {
    local profile="$1"
    local start_marker="# >>> agent-skills codex auto-update >>>"
    local end_marker="# <<< agent-skills codex auto-update <<<"
    local source_line='[ -f "$HOME/.codex/codex-skills-auto-update.sh" ] && source "$HOME/.codex/codex-skills-auto-update.sh"'
    local tmp_file="${profile}.tmp.$$"

    mkdir -p "$(dirname "$profile")"
    [ -f "$profile" ] || touch "$profile"

    if grep -Fq "$start_marker" "$profile"; then
        awk -v start="$start_marker" -v end="$end_marker" -v line="$source_line" '
            $0 == start {
                print
                print line
                in_block = 1
                next
            }
            $0 == end {
                in_block = 0
                print
                next
            }
            !in_block { print }
        ' "$profile" > "$tmp_file"
        mv "$tmp_file" "$profile"
    else
        {
            echo ""
            echo "$start_marker"
            echo "$source_line"
            echo "$end_marker"
        } >> "$profile"
    fi
}

sync_codex_local_version() {
    local version_file="$TEMP_DIR/skills-repo/scripts/manifest/version.txt"
    local version=""

    if [ -f "$version_file" ]; then
        version="$(tr -d '[:space:]' < "$version_file")"
    fi

    # 回退到 commit hash，避免缺失 version 文件时失效
    if [ -z "$version" ]; then
        version="$(git -C "$TEMP_DIR/skills-repo" rev-parse --short=12 HEAD 2>/dev/null || true)"
    fi

    if [ -z "$version" ]; then
        log_warn "[Codex CLI] 无法写入本地 skills 版本（version/commit 均不可用）"
        return
    fi

    mkdir -p "$(dirname "$CODEX_LOCAL_VERSION_FILE")"
    printf '%s\n' "$version" > "$CODEX_LOCAL_VERSION_FILE"
    log_info "[Codex CLI] 已写入本地 skills 版本: $version"
}

configure_codex_auto_update_launcher() {
    local repo_slug="${CODEX_AUTO_UPDATE_REPO}"

    if ! is_truthy "$CODEX_AUTO_UPDATE_SETUP"; then
        log_info "[Codex CLI] 跳过自动更新启动器配置（CODEX_AUTO_UPDATE_SETUP=${CODEX_AUTO_UPDATE_SETUP}）"
        return
    fi

    if ! command -v curl &> /dev/null; then
        log_warn "[Codex CLI] 未检测到 curl，无法配置自动更新启动器"
        return
    fi

    if [ -z "$repo_slug" ]; then
        repo_slug="$(resolve_github_repo_slug "$REPO_URL")"
    fi
    if [ -z "$repo_slug" ]; then
        repo_slug="biglone/agent-skills"
        log_warn "[Codex CLI] 无法从 SKILLS_REPO 推断 GitHub 仓库，已回退为: $repo_slug"
    fi

    mkdir -p "$(dirname "$CODEX_AUTO_UPDATE_LOADER")"
    cat > "$CODEX_AUTO_UPDATE_LOADER" <<EOF
# Auto-generated by agent-skills/scripts/install.sh
# Set CODEX_SKILLS_AUTO_UPDATE=0 to disable auto update checks.
codex() {
  local repo="${repo_slug}"
  local branch="${CODEX_AUTO_UPDATE_BRANCH}"
  local version_url="https://raw.githubusercontent.com/\${repo}/\${branch}/scripts/manifest/version.txt"
  local install_url="https://raw.githubusercontent.com/\${repo}/\${branch}/scripts/install.sh"
  local local_ver_file="\$HOME/.codex/.skills_version"
  local remote_ver local_ver

  if [ "\${CODEX_SKILLS_AUTO_UPDATE:-1}" = "0" ]; then
    command codex "\$@"
    return
  fi

  remote_ver="\$(curl -fsSL --max-time 5 "\$version_url" 2>/dev/null | tr -d '[:space:]' || true)"
  local_ver="\$(cat "\$local_ver_file" 2>/dev/null | tr -d '[:space:]' || true)"

  if [ -n "\$remote_ver" ] && [ "\$remote_ver" != "\$local_ver" ]; then
    echo "[skills] update \$local_ver -> \$remote_ver"
    if curl -fsSL --max-time 20 "\$install_url" | UPDATE_MODE=force INSTALL_TARGET=codex CODEX_AUTO_UPDATE_SETUP=off SKILLS_REF="\$branch" bash; then
      printf '%s\n' "\$remote_ver" > "\$local_ver_file"
    else
      echo "[skills] auto-update failed, continue launching codex" >&2
    fi
  fi

  command codex "\$@"
}
EOF

    upsert_shell_source_block "$HOME/.bashrc"
    upsert_shell_source_block "$HOME/.zshrc"

    log_info "[Codex CLI] 已配置 codex 启动前自动检查 skills 更新"
    log_info "[Codex CLI] 配置文件: $CODEX_AUTO_UPDATE_LOADER"
}

check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi
}

select_target() {
    if [ -n "$INSTALL_TARGET" ]; then
        INSTALL_TARGET="$(printf '%s' "$INSTALL_TARGET" | tr '[:upper:]' '[:lower:]')"
        validate_install_target
        return
    fi

    if [ "$NON_INTERACTIVE" = "1" ]; then
        INSTALL_TARGET="both"
        log_info "非交互模式：默认安装到两者（INSTALL_TARGET=both）"
        return
    fi

    # 检查是否有可用的终端输入
    if [ ! -t 0 ] && [ ! -r /dev/tty ]; then
        log_warn "无法获取用户输入，默认安装到两者"
        INSTALL_TARGET="both"
        return
    fi

    echo -e "${CYAN}请选择安装目标:${NC}"
    echo "  1) Claude Code"
    echo "  2) OpenAI Codex CLI"
    echo "  3) 两者都安装"
    echo ""
    # 从 /dev/tty 读取，支持 curl | bash 方式
    read -p "请输入选项 [1-3] (默认: 3): " choice </dev/tty

    case "$choice" in
        1) INSTALL_TARGET="claude" ;;
        2) INSTALL_TARGET="codex" ;;
        3|"") INSTALL_TARGET="both" ;;
        *)
            log_warn "无效选项，默认安装到两者"
            INSTALL_TARGET="both"
            ;;
    esac

    validate_install_target
}

create_skills_dirs() {
    : > "$CLAUDE_INSTALLED_REPORT"
    : > "$CODEX_INSTALLED_REPORT"

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
            log_info "创建 Claude Code skills 目录: $CLAUDE_SKILLS_DIR"
            if [ "$DRY_RUN" != "1" ]; then
                mkdir -p "$CLAUDE_SKILLS_DIR"
            fi
        fi
        if [ ! -d "$CLAUDE_WORKFLOWS_DIR" ]; then
            log_info "创建 Claude Code workflows 目录: $CLAUDE_WORKFLOWS_DIR"
            if [ "$DRY_RUN" != "1" ]; then
                mkdir -p "$CLAUDE_WORKFLOWS_DIR"
            fi
        fi
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        if [ ! -d "$CODEX_SKILLS_DIR" ]; then
            log_info "创建 Codex CLI skills 目录: $CODEX_SKILLS_DIR"
            if [ "$DRY_RUN" != "1" ]; then
                mkdir -p "$CODEX_SKILLS_DIR"
            fi
        fi
        if [ ! -d "$CODEX_WORKFLOWS_DIR" ]; then
            log_info "创建 Codex CLI workflows 目录: $CODEX_WORKFLOWS_DIR"
            if [ "$DRY_RUN" != "1" ]; then
                mkdir -p "$CODEX_WORKFLOWS_DIR"
            fi
        fi
    fi
}

clone_repo() {
    log_info "克隆 skills 仓库..."
    log_debug "clone source: $REPO_URL"
    log_debug "clone ref: $SKILLS_REF"
    log_debug "clone target: $TEMP_DIR/skills-repo"
    git clone --depth 1 --branch "$SKILLS_REF" "$REPO_URL" "$TEMP_DIR/skills-repo" || {
        log_error "克隆仓库失败，请检查仓库地址/引用: $REPO_URL @ $SKILLS_REF"
        exit 1
    }

    set_manifests
}

# 询问用户是否更新单个 skill
ask_update_skill() {
    local skill_name="$1"
    local target_name="$2"

    if [ "$UPDATE_MODE" = "skip" ]; then
        return 1  # 不更新
    elif [ "$UPDATE_MODE" = "force" ]; then
        return 0  # 更新
    fi

    # ask 模式：询问用户（从 /dev/tty 读取，支持 curl | bash）
    if [ "$NON_INTERACTIVE" = "1" ]; then
        if [ "$ASK_FALLBACK_WARNED" -eq 0 ]; then
            log_warn "非交互模式下 UPDATE_MODE=ask，将按 force 处理"
            ASK_FALLBACK_WARNED=1
        fi
        return 0
    fi

    if [ ! -t 0 ] && [ ! -r /dev/tty ]; then
        if [ "$ASK_FALLBACK_WARNED" -eq 0 ]; then
            log_warn "无法交互且 UPDATE_MODE=ask，将按 force 处理"
            ASK_FALLBACK_WARNED=1
        fi
        return 0
    fi

    echo ""
    read -p "[$target_name] Skill '$skill_name' 已存在，是否更新? [y/N]: " answer </dev/tty
    case "$answer" in
        [Yy]|[Yy][Ee][Ss]) return 0 ;;
        *) return 1 ;;
    esac
}

install_skills_to_dir() {
    local target_dir="$1"
    local target_name="$2"
    local report_file="$3"
    local source_dir="$TEMP_DIR/skills-repo/skills"

    log_info "安装 skills 到 $target_name..."

    while IFS= read -r skill_name; do
        [ -z "$skill_name" ] && continue
        local skill="$source_dir/$skill_name"
        local skill_target="$target_dir/$skill_name"

        if [ ! -d "$skill" ]; then
            log_warn "[$target_name] manifest 中的 skill 不存在，跳过: $skill_name"
            continue
        fi

        if [ -d "$skill_target" ]; then
            if ask_update_skill "$skill_name" "$target_name"; then
                if [ "$DRY_RUN" = "1" ]; then
                    log_info "[DRY-RUN][$target_name] 将更新: $skill_name"
                else
                    rm -rf "$skill_target"
                    cp -r "$skill" "$target_dir/"
                    log_info "[$target_name] 已更新: $skill_name"
                fi
                echo "$skill_name" >> "$report_file"
            else
                log_warn "[$target_name] 跳过: $skill_name"
            fi
        else
            if [ "$DRY_RUN" = "1" ]; then
                log_info "[DRY-RUN][$target_name] 将安装: $skill_name"
            else
                cp -r "$skill" "$target_dir/"
                log_info "[$target_name] 已安装: $skill_name"
            fi
            echo "$skill_name" >> "$report_file"
        fi
    done < <(read_manifest_entries "$SKILLS_MANIFEST_FILE")
}

install_skills() {
    local source_dir="$TEMP_DIR/skills-repo/skills"

    if [ ! -d "$source_dir" ]; then
        log_error "skills 目录不存在"
        exit 1
    fi

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_skills_to_dir "$CLAUDE_SKILLS_DIR" "Claude Code" "$CLAUDE_INSTALLED_REPORT"
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_skills_to_dir "$CODEX_SKILLS_DIR" "Codex CLI" "$CODEX_INSTALLED_REPORT"
    fi
}

install_workflows_to_dir() {
    local target_dir="$1"
    local target_name="$2"
    local source_dir="$TEMP_DIR/skills-repo/workflows"

    log_info "安装 workflows 到 $target_name..."

    if [ ! -f "$WORKFLOWS_MANIFEST_FILE" ]; then
        log_warn "workflows manifest 缺失，跳过 workflows 安装"
        return
    fi

    while IFS= read -r workflow_name; do
        [ -z "$workflow_name" ] && continue
        local workflow="$source_dir/$workflow_name"
        local workflow_target="$target_dir/$workflow_name"

        if [ ! -d "$workflow" ]; then
            log_warn "[$target_name] manifest 中的 workflow 不存在，跳过: $workflow_name"
            continue
        fi

        if [ -d "$workflow_target" ]; then
            if ask_update_skill "$workflow_name" "$target_name"; then
                if [ "$DRY_RUN" = "1" ]; then
                    log_info "[DRY-RUN][$target_name] 将更新 workflow: $workflow_name"
                else
                    rm -rf "$workflow_target"
                    cp -r "$workflow" "$target_dir/"
                    log_info "[$target_name] 已更新 workflow: $workflow_name"
                fi
            else
                log_warn "[$target_name] 跳过 workflow: $workflow_name"
            fi
        else
            if [ "$DRY_RUN" = "1" ]; then
                log_info "[DRY-RUN][$target_name] 将安装 workflow: $workflow_name"
            else
                cp -r "$workflow" "$target_dir/"
                log_info "[$target_name] 已安装 workflow: $workflow_name"
            fi
        fi
    done < <(read_manifest_entries "$WORKFLOWS_MANIFEST_FILE")
}

install_workflows() {
    local source_dir="$TEMP_DIR/skills-repo/workflows"

    if [ ! -d "$source_dir" ]; then
        log_warn "workflows 目录不存在，跳过"
        return
    fi

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_workflows_to_dir "$CLAUDE_WORKFLOWS_DIR" "Claude Code"
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_workflows_to_dir "$CODEX_WORKFLOWS_DIR" "Codex CLI"
    fi
}

show_installed() {
    local skills_dir="$1"
    local name="$2"
    local report_file="$3"

    if [ ! -d "$skills_dir" ] && [ "$DRY_RUN" != "1" ]; then
        return
    fi

    echo ""
    log_info "$name 本次安装/更新的 Skills:"
    echo "─────────────────────────────────────────"
    if [ ! -s "$report_file" ]; then
        echo "  (无变更)"
        echo "─────────────────────────────────────────"
        return
    fi

    while IFS= read -r skill_name; do
        [ -z "$skill_name" ] && continue
        if [ "$DRY_RUN" = "1" ]; then
            echo "  • $skill_name (planned)"
            continue
        fi

        skill="$skills_dir/$skill_name"
        if [ -d "$skill" ] && [ -f "$skill/SKILL.md" ]; then
            desc=$(grep "^description:" "$skill/SKILL.md" 2>/dev/null | head -1 | sed 's/description: //')
            echo "  • $skill_name"
            if [ -n "$desc" ]; then
                echo "    $desc"
            fi
        fi
    done < <(sort -u "$report_file")
    echo "─────────────────────────────────────────"
}

main() {
    parse_args "$@"

    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║     AI Coding Skills 安装程序             ║"
    echo "║     支持 Claude Code / Codex CLI          ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""
    if [ "$DRY_RUN" = "1" ]; then
        log_info "已启用 dry-run：不会写入目标目录"
    fi

    check_git
    validate_update_mode
    validate_install_target
    select_target
    create_skills_dirs
    clone_repo
    install_skills
    install_workflows

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        if [ "$DRY_RUN" = "1" ]; then
            log_info "[DRY-RUN] 跳过写入 Codex 本地版本与自动更新配置"
        else
            sync_codex_local_version
            configure_codex_auto_update_launcher
        fi
    fi

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        show_installed "$CLAUDE_SKILLS_DIR" "Claude Code" "$CLAUDE_INSTALLED_REPORT"
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        show_installed "$CODEX_SKILLS_DIR" "Codex CLI" "$CODEX_INSTALLED_REPORT"
    fi

    echo ""
    log_info "安装完成! 请重启对应的 AI 编程工具以加载 Skills"
    if [ "$DRY_RUN" != "1" ] && { [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; }; then
        log_info "Codex 自动更新配置已写入 ~/.bashrc 和 ~/.zshrc，新终端会生效"
    fi
}

main "$@"

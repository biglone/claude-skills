#!/bin/bash

# AI Coding Skills 卸载脚本
# 支持 Claude Code 和 OpenAI Codex CLI

set -e

CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"

UNINSTALL_TARGET="${UNINSTALL_TARGET:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

SKILLS_TO_REMOVE=(
    "code-reviewer"
    "commit-message"
    "security-audit"
    "code-explainer"
    "test-generator"
)

select_target() {
    if [ -n "$UNINSTALL_TARGET" ]; then
        return
    fi

    echo -e "${CYAN}请选择卸载目标:${NC}"
    echo "  1) Claude Code"
    echo "  2) OpenAI Codex CLI"
    echo "  3) 两者都卸载"
    echo ""
    read -p "请输入选项 [1-3] (默认: 3): " choice

    case "$choice" in
        1) UNINSTALL_TARGET="claude" ;;
        2) UNINSTALL_TARGET="codex" ;;
        3|"") UNINSTALL_TARGET="both" ;;
        *) UNINSTALL_TARGET="both" ;;
    esac
}

uninstall_from_dir() {
    local target_dir="$1"
    local target_name="$2"

    for skill in "${SKILLS_TO_REMOVE[@]}"; do
        skill_path="$target_dir/$skill"
        if [ -d "$skill_path" ]; then
            rm -rf "$skill_path"
            log_info "[$target_name] 已卸载: $skill"
        else
            log_warn "[$target_name] Skill '$skill' 不存在，跳过"
        fi
    done
}

main() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║     AI Coding Skills 卸载程序             ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""

    select_target

    if [ "$UNINSTALL_TARGET" = "claude" ] || [ "$UNINSTALL_TARGET" = "both" ]; then
        uninstall_from_dir "$CLAUDE_SKILLS_DIR" "Claude Code"
    fi

    if [ "$UNINSTALL_TARGET" = "codex" ] || [ "$UNINSTALL_TARGET" = "both" ]; then
        uninstall_from_dir "$CODEX_SKILLS_DIR" "Codex CLI"
    fi

    echo ""
    log_info "卸载完成! 请重启对应的 AI 编程工具"
}

main "$@"

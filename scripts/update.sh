#!/bin/bash

# AI Coding Skills 更新脚本
# 支持 Claude Code 和 OpenAI Codex CLI

set -e

REPO_URL="${SKILLS_REPO:-https://github.com/biglone/claude-skills.git}"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
TEMP_DIR=$(mktemp -d)

UPDATE_TARGET="${UPDATE_TARGET:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

select_target() {
    if [ -n "$UPDATE_TARGET" ]; then
        return
    fi

    # 检查是否有可用的终端输入
    if [ ! -t 0 ] && [ ! -e /dev/tty ]; then
        log_warn "无法获取用户输入，默认更新两者"
        UPDATE_TARGET="both"
        return
    fi

    echo -e "${CYAN}请选择更新目标:${NC}"
    echo "  1) Claude Code"
    echo "  2) OpenAI Codex CLI"
    echo "  3) 两者都更新"
    echo ""
    read -p "请输入选项 [1-3] (默认: 3): " choice </dev/tty

    case "$choice" in
        1) UPDATE_TARGET="claude" ;;
        2) UPDATE_TARGET="codex" ;;
        3|"") UPDATE_TARGET="both" ;;
        *) UPDATE_TARGET="both" ;;
    esac
}

update_skills_in_dir() {
    local target_dir="$1"
    local target_name="$2"
    local source_dir="$TEMP_DIR/skills-repo/skills"

    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    for skill in "$source_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            skill_target="$target_dir/$skill_name"

            if [ -d "$skill_target" ]; then
                rm -rf "$skill_target"
                log_info "[$target_name] 更新: $skill_name"
            else
                log_info "[$target_name] 新增: $skill_name"
            fi
            cp -r "$skill" "$target_dir/"
        fi
    done
}

main() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║     AI Coding Skills 更新程序             ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""

    if ! command -v git &> /dev/null; then
        log_error "Git 未安装"
        exit 1
    fi

    select_target

    log_info "获取最新 skills..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/skills-repo" 2>/dev/null || {
        log_error "克隆仓库失败"
        exit 1
    }

    if [ "$UPDATE_TARGET" = "claude" ] || [ "$UPDATE_TARGET" = "both" ]; then
        update_skills_in_dir "$CLAUDE_SKILLS_DIR" "Claude Code"
    fi

    if [ "$UPDATE_TARGET" = "codex" ] || [ "$UPDATE_TARGET" = "both" ]; then
        update_skills_in_dir "$CODEX_SKILLS_DIR" "Codex CLI"
    fi

    echo ""
    log_info "更新完成! 请重启对应的 AI 编程工具"
}

main "$@"

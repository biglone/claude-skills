#!/bin/bash

# AI Coding Skills 更新脚本
# 支持 Claude Code 和 OpenAI Codex CLI

set -e

REPO_URL="${SKILLS_REPO:-https://github.com/biglone/claude-skills.git}"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
CLAUDE_WORKFLOWS_DIR="$HOME/.claude/workflows"
CODEX_WORKFLOWS_DIR="$HOME/.codex/workflows"
TEMP_DIR=$(mktemp -d)

UPDATE_TARGET="${UPDATE_TARGET:-}"
PRUNE_MODE="${PRUNE_MODE:-off}"  # on/off: 是否清理本地已下线的 skill/workflow
DEBUG="${DEBUG:-0}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() {
    if [ "$DEBUG" = "1" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
}

cleanup() { rm -rf "$TEMP_DIR"; }
trap cleanup EXIT

prune_removed_dirs() {
    local target_dir="$1"
    local source_dir="$2"
    local target_name="$3"
    local item_label="$4"

    [ -d "$target_dir" ] || return
    [ -d "$source_dir" ] || return

    for item in "$target_dir"/*; do
        [ -d "$item" ] || continue
        item_name=$(basename "$item")
        if [ ! -d "$source_dir/$item_name" ]; then
            rm -rf "$item"
            log_info "[$target_name] 清理已下线 $item_label: $item_name"
        fi
    done
}

select_target() {
    if [ -n "$UPDATE_TARGET" ]; then
        return
    fi

    # 检查是否有可用的终端输入
    if [ ! -t 0 ] && [ ! -r /dev/tty ]; then
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

    if [ "$PRUNE_MODE" = "on" ]; then
        prune_removed_dirs "$target_dir" "$source_dir" "$target_name" "skill"
    fi
}

update_workflows_in_dir() {
    local target_dir="$1"
    local target_name="$2"
    local source_dir="$TEMP_DIR/skills-repo/workflows"

    if [ ! -d "$source_dir" ]; then
        log_warn "workflows 目录不存在，跳过"
        return
    fi

    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    for workflow in "$source_dir"/*; do
        if [ -d "$workflow" ]; then
            workflow_name=$(basename "$workflow")
            workflow_target="$target_dir/$workflow_name"

            if [ -d "$workflow_target" ]; then
                rm -rf "$workflow_target"
                log_info "[$target_name] 更新 workflow: $workflow_name"
            else
                log_info "[$target_name] 新增 workflow: $workflow_name"
            fi
            cp -r "$workflow" "$target_dir/"
        fi
    done

    if [ "$PRUNE_MODE" = "on" ]; then
        prune_removed_dirs "$target_dir" "$source_dir" "$target_name" "workflow"
    fi
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

    if [ "$PRUNE_MODE" != "on" ] && [ "$PRUNE_MODE" != "off" ]; then
        log_warn "PRUNE_MODE 仅支持 on/off，当前为 '$PRUNE_MODE'，已自动降级为 off"
        PRUNE_MODE="off"
    fi

    log_info "获取最新 skills..."
    log_debug "clone source: $REPO_URL"
    log_debug "clone target: $TEMP_DIR/skills-repo"
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/skills-repo" || {
        log_error "克隆仓库失败"
        exit 1
    }

    if [ "$UPDATE_TARGET" = "claude" ] || [ "$UPDATE_TARGET" = "both" ]; then
        update_skills_in_dir "$CLAUDE_SKILLS_DIR" "Claude Code"
        update_workflows_in_dir "$CLAUDE_WORKFLOWS_DIR" "Claude Code"
    fi

    if [ "$UPDATE_TARGET" = "codex" ] || [ "$UPDATE_TARGET" = "both" ]; then
        update_skills_in_dir "$CODEX_SKILLS_DIR" "Codex CLI"
        update_workflows_in_dir "$CODEX_WORKFLOWS_DIR" "Codex CLI"
    fi

    echo ""
    log_info "更新完成! 请重启对应的 AI 编程工具"
}

main "$@"

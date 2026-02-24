#!/bin/bash

# AI Skills 卸载脚本
# 支持 Claude Code 和 OpenAI Codex CLI

set -euo pipefail

CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
CLAUDE_WORKFLOWS_DIR="$HOME/.claude/workflows"
CODEX_WORKFLOWS_DIR="$HOME/.codex/workflows"

UNINSTALL_TARGET="${UNINSTALL_TARGET:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

SKILLS_TO_REMOVE=(
    # 编程开发类
    "code-reviewer"
    "commit-message"
    "security-audit"
    "code-explainer"
    "test-generator"
    "refactoring"
    "api-designer"
    "doc-generator"
    "performance-optimizer"
    "bug-finder"
    "regex-helper"
    "sql-helper"
    "git-helper"
    "changelog-generator"
    "pr-description"
    "dependency-analyzer"
    "i18n-helper"
    "migration-helper"
    # 写作与翻译类
    "technical-writer"
    "blog-writer"
    "translator"
    "email-writer"
    "presentation-maker"
    # 数据与分析类
    "data-analyzer"
    "chart-generator"
    # 学习与知识管理类
    "concept-explainer"
    "tutorial-creator"
    "note-taker"
    "knowledge-base"
    "learning-tracker"
    # 个人效率类
    "task-planner"
    "meeting-notes"
    "weekly-review"
    "goal-setter"
    "habit-tracker"
    "decision-maker"
    # 职业发展类
    "resume-builder"
    "interview-helper"
    "career-planner"
    "feedback-giver"
    # 创意思考类
    "brainstormer"
    "outline-creator"
    "mind-mapper"
    # 自动化类
    "autonomous-dev"
    "auto-code-pipeline"
    "auto-fix-loop"
    "requirements-doc"
)

WORKFLOWS_TO_REMOVE=(
    "full-auto-development"
    "code-review-flow"
    "feature-development"
    "content-creation"
    "weekly-planning"
    "learning-path"
    "project-kickoff"
)

select_target() {
    if [ -n "$UNINSTALL_TARGET" ]; then
        return
    fi

    # 检查是否有可用的终端输入
    if [ ! -t 0 ] && [ ! -r /dev/tty ]; then
        log_warn "无法获取用户输入，默认卸载两者"
        UNINSTALL_TARGET="both"
        return
    fi

    echo -e "${CYAN}请选择卸载目标:${NC}"
    echo "  1) Claude Code"
    echo "  2) OpenAI Codex CLI"
    echo "  3) 两者都卸载"
    echo ""
    read -p "请输入选项 [1-3] (默认: 3): " choice </dev/tty

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

uninstall_workflows_from_dir() {
    local target_dir="$1"
    local target_name="$2"

    for workflow in "${WORKFLOWS_TO_REMOVE[@]}"; do
        workflow_path="$target_dir/$workflow"
        if [ -d "$workflow_path" ]; then
            rm -rf "$workflow_path"
            log_info "[$target_name] 已卸载 workflow: $workflow"
        else
            log_warn "[$target_name] Workflow '$workflow' 不存在，跳过"
        fi
    done
}

main() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║       AI Skills 卸载程序                  ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""

    select_target

    if [ "$UNINSTALL_TARGET" = "claude" ] || [ "$UNINSTALL_TARGET" = "both" ]; then
        uninstall_from_dir "$CLAUDE_SKILLS_DIR" "Claude Code"
        uninstall_workflows_from_dir "$CLAUDE_WORKFLOWS_DIR" "Claude Code"
    fi

    if [ "$UNINSTALL_TARGET" = "codex" ] || [ "$UNINSTALL_TARGET" = "both" ]; then
        uninstall_from_dir "$CODEX_SKILLS_DIR" "Codex CLI"
        uninstall_workflows_from_dir "$CODEX_WORKFLOWS_DIR" "Codex CLI"
    fi

    echo ""
    log_info "卸载完成! 请重启对应的 AI 编程工具"
}

main "$@"

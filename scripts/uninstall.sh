#!/bin/bash

# Claude Skills 卸载脚本

set -e

SKILLS_DIR="$HOME/.claude/skills"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 要卸载的 skills 列表
SKILLS_TO_REMOVE=(
    "code-reviewer"
    "commit-message"
    "security-audit"
    "code-explainer"
    "test-generator"
)

main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Claude Skills 卸载程序            ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    for skill in "${SKILLS_TO_REMOVE[@]}"; do
        skill_path="$SKILLS_DIR/$skill"
        if [ -d "$skill_path" ]; then
            rm -rf "$skill_path"
            log_info "已卸载: $skill"
        else
            log_warn "Skill '$skill' 不存在，跳过"
        fi
    done

    echo ""
    log_info "卸载完成! 请重启 Claude Code"
}

main "$@"

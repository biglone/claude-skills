#!/bin/bash

# Claude Skills 更新脚本
# 强制更新所有 skills（覆盖已存在的）

set -e

REPO_URL="${CLAUDE_SKILLS_REPO:-https://github.com/biglone/claude-skills.git}"
SKILLS_DIR="$HOME/.claude/skills"
TEMP_DIR=$(mktemp -d)

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

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Claude Skills 更新程序            ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    # 检查 git
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装"
        exit 1
    fi

    # 创建目录
    mkdir -p "$SKILLS_DIR"

    # 克隆仓库
    log_info "获取最新 skills..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/claude-skills" 2>/dev/null || {
        log_error "克隆仓库失败"
        exit 1
    }

    # 更新 skills
    local source_dir="$TEMP_DIR/claude-skills/skills"

    for skill in "$source_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            target_dir="$SKILLS_DIR/$skill_name"

            if [ -d "$target_dir" ]; then
                rm -rf "$target_dir"
                log_info "更新: $skill_name"
            else
                log_info "新增: $skill_name"
            fi
            cp -r "$skill" "$SKILLS_DIR/"
        fi
    done

    echo ""
    log_info "更新完成! 请重启 Claude Code"
}

main "$@"

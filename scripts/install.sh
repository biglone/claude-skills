#!/bin/bash

# Claude Skills 安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/<user>/claude-skills/main/scripts/install.sh | bash

set -e

# 配置
REPO_URL="${CLAUDE_SKILLS_REPO:-https://github.com/biglone/claude-skills.git}"
SKILLS_DIR="$HOME/.claude/skills"
TEMP_DIR=$(mktemp -d)

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 清理临时目录
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# 检查 git 是否安装
check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi
}

# 创建 skills 目录
create_skills_dir() {
    if [ ! -d "$SKILLS_DIR" ]; then
        log_info "创建 skills 目录: $SKILLS_DIR"
        mkdir -p "$SKILLS_DIR"
    fi
}

# 克隆仓库
clone_repo() {
    log_info "克隆 skills 仓库..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/claude-skills" 2>/dev/null || {
        log_error "克隆仓库失败，请检查仓库地址: $REPO_URL"
        exit 1
    }
}

# 安装 skills
install_skills() {
    local source_dir="$TEMP_DIR/claude-skills/skills"

    if [ ! -d "$source_dir" ]; then
        log_error "skills 目录不存在"
        exit 1
    fi

    log_info "安装 skills..."

    for skill in "$source_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            target_dir="$SKILLS_DIR/$skill_name"

            if [ -d "$target_dir" ]; then
                log_warn "Skill '$skill_name' 已存在，跳过"
            else
                cp -r "$skill" "$SKILLS_DIR/"
                log_info "已安装: $skill_name"
            fi
        fi
    done
}

# 显示已安装的 skills
show_installed() {
    echo ""
    log_info "已安装的 Skills:"
    echo "─────────────────────────────────"
    for skill in "$SKILLS_DIR"/*; do
        if [ -d "$skill" ] && [ -f "$skill/SKILL.md" ]; then
            skill_name=$(basename "$skill")
            # 提取 description
            desc=$(grep -A1 "^description:" "$skill/SKILL.md" 2>/dev/null | head -1 | sed 's/description: //')
            echo "  • $skill_name"
            if [ -n "$desc" ]; then
                echo "    $desc"
            fi
        fi
    done
    echo "─────────────────────────────────"
    echo ""
    log_info "请重启 Claude Code 以加载新的 Skills"
}

# 主函数
main() {
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║     Claude Skills 安装程序            ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    check_git
    create_skills_dir
    clone_repo
    install_skills
    show_installed

    log_info "安装完成!"
}

main "$@"

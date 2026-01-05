#!/bin/bash

# AI Coding Skills 安装脚本
# 支持 Claude Code 和 OpenAI Codex CLI
# 用法: curl -fsSL https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.sh | bash

set -e

# 配置
REPO_URL="${SKILLS_REPO:-https://github.com/biglone/claude-skills.git}"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
CODEX_SKILLS_DIR="$HOME/.codex/skills"
CLAUDE_WORKFLOWS_DIR="$HOME/.claude/workflows"
CODEX_WORKFLOWS_DIR="$HOME/.codex/workflows"
TEMP_DIR=$(mktemp -d)

# 安装目标 (claude, codex, both)
INSTALL_TARGET="${INSTALL_TARGET:-}"

# 更新模式 (ask, skip, force)
# ask: 询问用户是否更新已存在的 skill (默认)
# skip: 跳过已存在的 skill
# force: 强制更新所有 skill
UPDATE_MODE="${UPDATE_MODE:-ask}"

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

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

check_git() {
    if ! command -v git &> /dev/null; then
        log_error "Git 未安装，请先安装 Git"
        exit 1
    fi
}

select_target() {
    if [ -n "$INSTALL_TARGET" ]; then
        return
    fi

    # 检查是否有可用的终端输入
    if [ ! -t 0 ] && [ ! -e /dev/tty ]; then
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
}

create_skills_dirs() {
    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        if [ ! -d "$CLAUDE_SKILLS_DIR" ]; then
            log_info "创建 Claude Code skills 目录: $CLAUDE_SKILLS_DIR"
            mkdir -p "$CLAUDE_SKILLS_DIR"
        fi
        if [ ! -d "$CLAUDE_WORKFLOWS_DIR" ]; then
            log_info "创建 Claude Code workflows 目录: $CLAUDE_WORKFLOWS_DIR"
            mkdir -p "$CLAUDE_WORKFLOWS_DIR"
        fi
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        if [ ! -d "$CODEX_SKILLS_DIR" ]; then
            log_info "创建 Codex CLI skills 目录: $CODEX_SKILLS_DIR"
            mkdir -p "$CODEX_SKILLS_DIR"
        fi
        if [ ! -d "$CODEX_WORKFLOWS_DIR" ]; then
            log_info "创建 Codex CLI workflows 目录: $CODEX_WORKFLOWS_DIR"
            mkdir -p "$CODEX_WORKFLOWS_DIR"
        fi
    fi
}

clone_repo() {
    log_info "克隆 skills 仓库..."
    git clone --depth 1 "$REPO_URL" "$TEMP_DIR/skills-repo" 2>/dev/null || {
        log_error "克隆仓库失败，请检查仓库地址: $REPO_URL"
        exit 1
    }
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
    if [ ! -t 0 ] && [ ! -e /dev/tty ]; then
        # 无法交互时默认跳过
        return 1
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
    local source_dir="$TEMP_DIR/skills-repo/skills"

    log_info "安装 skills 到 $target_name..."

    for skill in "$source_dir"/*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            skill_target="$target_dir/$skill_name"

            if [ -d "$skill_target" ]; then
                if ask_update_skill "$skill_name" "$target_name"; then
                    rm -rf "$skill_target"
                    cp -r "$skill" "$target_dir/"
                    log_info "[$target_name] 已更新: $skill_name"
                else
                    log_warn "[$target_name] 跳过: $skill_name"
                fi
            else
                cp -r "$skill" "$target_dir/"
                log_info "[$target_name] 已安装: $skill_name"
            fi
        fi
    done
}

install_skills() {
    local source_dir="$TEMP_DIR/skills-repo/skills"

    if [ ! -d "$source_dir" ]; then
        log_error "skills 目录不存在"
        exit 1
    fi

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_skills_to_dir "$CLAUDE_SKILLS_DIR" "Claude Code"
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        install_skills_to_dir "$CODEX_SKILLS_DIR" "Codex CLI"
    fi
}

install_workflows_to_dir() {
    local target_dir="$1"
    local target_name="$2"
    local source_dir="$TEMP_DIR/skills-repo/workflows"

    log_info "安装 workflows 到 $target_name..."

    for workflow in "$source_dir"/*; do
        if [ -d "$workflow" ]; then
            workflow_name=$(basename "$workflow")
            workflow_target="$target_dir/$workflow_name"

            if [ -d "$workflow_target" ]; then
                if ask_update_skill "$workflow_name" "$target_name"; then
                    rm -rf "$workflow_target"
                    cp -r "$workflow" "$target_dir/"
                    log_info "[$target_name] 已更新 workflow: $workflow_name"
                else
                    log_warn "[$target_name] 跳过 workflow: $workflow_name"
                fi
            else
                cp -r "$workflow" "$target_dir/"
                log_info "[$target_name] 已安装 workflow: $workflow_name"
            fi
        fi
    done
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

    if [ ! -d "$skills_dir" ]; then
        return
    fi

    echo ""
    log_info "$name 已安装的 Skills:"
    echo "─────────────────────────────────────────"
    for skill in "$skills_dir"/*; do
        if [ -d "$skill" ] && [ -f "$skill/SKILL.md" ]; then
            skill_name=$(basename "$skill")
            desc=$(grep "^description:" "$skill/SKILL.md" 2>/dev/null | head -1 | sed 's/description: //')
            echo "  • $skill_name"
            if [ -n "$desc" ]; then
                echo "    $desc"
            fi
        fi
    done
    echo "─────────────────────────────────────────"
}

main() {
    echo ""
    echo "╔═══════════════════════════════════════════╗"
    echo "║     AI Coding Skills 安装程序             ║"
    echo "║     支持 Claude Code / Codex CLI          ║"
    echo "╚═══════════════════════════════════════════╝"
    echo ""

    check_git
    select_target
    create_skills_dirs
    clone_repo
    install_skills
    install_workflows

    if [ "$INSTALL_TARGET" = "claude" ] || [ "$INSTALL_TARGET" = "both" ]; then
        show_installed "$CLAUDE_SKILLS_DIR" "Claude Code"
    fi

    if [ "$INSTALL_TARGET" = "codex" ] || [ "$INSTALL_TARGET" = "both" ]; then
        show_installed "$CODEX_SKILLS_DIR" "Codex CLI"
    fi

    echo ""
    log_info "安装完成! 请重启对应的 AI 编程工具以加载 Skills"
}

main "$@"

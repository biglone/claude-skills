#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"

errors=0
warnings=0

log_info() {
    echo "[INFO] $1"
}

log_warn() {
    echo "[WARN] $1"
    warnings=$((warnings + 1))
}

log_error() {
    echo "[ERROR] $1"
    errors=$((errors + 1))
}

validate_frontmatter() {
    local skill_dir="$1"
    local skill_file="$skill_dir/SKILL.md"
    local folder_name
    folder_name="$(basename "$skill_dir")"

    if [ ! -f "$skill_file" ]; then
        log_error "$folder_name: SKILL.md 不存在"
        return
    fi

    if [ "$(head -n 1 "$skill_file")" != "---" ]; then
        log_error "$folder_name: frontmatter 缺少起始 ---"
        return
    fi

    local end_line
    end_line="$(awk 'NR > 1 && $0 == "---" { print NR; exit }' "$skill_file")"
    if [ -z "$end_line" ]; then
        log_error "$folder_name: frontmatter 缺少结束 ---"
        return
    fi

    local fm
    fm="$(sed -n "2,$((end_line - 1))p" "$skill_file")"

    local name
    name="$(printf "%s\n" "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
    local description
    description="$(printf "%s\n" "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -1)"

    if [ -z "$name" ]; then
        log_error "$folder_name: frontmatter 缺少 name"
    fi

    if [ -z "$description" ]; then
        log_error "$folder_name: frontmatter 缺少 description"
    fi

    if [ -n "$name" ] && [ "$name" != "$folder_name" ]; then
        log_error "$folder_name: name($name) 与目录名不一致"
    fi

    if [ -n "$description" ]; then
        if ! printf "%s\n" "$description" | rg -qi "当用户|use when|when"; then
            log_warn "$folder_name: description 建议显式包含触发条件"
        fi
    fi
}

validate_code_fences() {
    local skill_dir="$1"
    local folder_name
    folder_name="$(basename "$skill_dir")"

    while IFS= read -r md_file; do
        local fence_count
        fence_count="$(awk '{ line=$0; c+=gsub(/```/, "", line) } END{ print c+0 }' "$md_file")"
        if [ $((fence_count % 2)) -ne 0 ]; then
            local rel_path
            rel_path="${md_file#$ROOT_DIR/}"
            log_error "$folder_name: $rel_path 代码块围栏未闭合"
        fi
    done < <(find "$skill_dir" -type f -name '*.md' | sort)
}

validate_reference_links() {
    local skill_dir="$1"
    local folder_name
    folder_name="$(basename "$skill_dir")"
    local skill_file="$skill_dir/SKILL.md"

    while IFS= read -r rel; do
        [ -z "$rel" ] && continue
        if [ ! -f "$skill_dir/$rel" ]; then
            log_error "$folder_name: 引用文件不存在 -> $rel"
        fi
    done < <(rg -o 'references/[A-Za-z0-9._/-]+\.md' "$skill_file" | sort -u || true)
}

validate_length() {
    local skill_dir="$1"
    local skill_file="$skill_dir/SKILL.md"
    local folder_name
    folder_name="$(basename "$skill_dir")"
    local line_count
    line_count="$(wc -l < "$skill_file" | tr -d ' ')"

    if [ "$line_count" -gt 500 ]; then
        log_warn "$folder_name: SKILL.md 行数 $line_count，建议拆分到 references/"
    fi
}

validate_dangerous_patterns() {
    local skill_dir="$1"
    local folder_name
    folder_name="$(basename "$skill_dir")"

    local patterns=(
        'git reset --hard'
        'git checkout -- '
        'git filter-branch'
        'rm -rf node_modules package-lock.json'
    )

    local matched=0
    for pattern in "${patterns[@]}"; do
        local hits
        hits="$(rg -n --fixed-strings "$pattern" "$skill_dir" -g '*.md' || true)"
        if [ -n "$hits" ]; then
            if [ "$matched" -eq 0 ]; then
                log_error "$folder_name: 检测到危险命令示例"
                matched=1
            fi
            echo "$hits" | sed 's/^/  - /'
        fi
    done
}

main() {
    if [ ! -d "$SKILLS_DIR" ]; then
        echo "[ERROR] skills 目录不存在: $SKILLS_DIR"
        exit 1
    fi

    log_info "开始校验 skills 目录: $SKILLS_DIR"

    while IFS= read -r skill_dir; do
        validate_frontmatter "$skill_dir"
        validate_code_fences "$skill_dir"
        validate_reference_links "$skill_dir"
        validate_length "$skill_dir"
        validate_dangerous_patterns "$skill_dir"
    done < <(find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort)

    echo
    echo "校验完成: errors=$errors warnings=$warnings"

    if [ "$errors" -gt 0 ]; then
        exit 1
    fi
}

main "$@"

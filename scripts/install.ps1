# Claude Skills 安装脚本 (Windows PowerShell)
# 用法: irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"

# 配置
$RepoUrl = if ($env:CLAUDE_SKILLS_REPO) { $env:CLAUDE_SKILLS_REPO } else { "https://github.com/biglone/claude-skills.git" }
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$TempDir = Join-Path $env:TEMP "claude-skills-$(Get-Random)"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Test-Git {
    try {
        git --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Claude Skills 安装程序            ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # 检查 Git
    if (-not (Test-Git)) {
        Write-Err "Git 未安装，请先安装 Git"
        exit 1
    }

    # 创建 skills 目录
    if (-not (Test-Path $SkillsDir)) {
        Write-Info "创建 skills 目录: $SkillsDir"
        New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    }

    # 克隆仓库
    Write-Info "克隆 skills 仓库..."
    try {
        git clone --depth 1 $RepoUrl $TempDir 2>$null
    } catch {
        Write-Err "克隆仓库失败，请检查仓库地址: $RepoUrl"
        exit 1
    }

    # 安装 skills
    $SourceDir = Join-Path $TempDir "skills"

    if (-not (Test-Path $SourceDir)) {
        Write-Err "skills 目录不存在"
        exit 1
    }

    Write-Info "安装 skills..."

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $TargetDir = Join-Path $SkillsDir $SkillName

        if (Test-Path $TargetDir) {
            Write-Warn "Skill '$SkillName' 已存在，跳过"
        } else {
            Copy-Item -Path $_.FullName -Destination $SkillsDir -Recurse
            Write-Info "已安装: $SkillName"
        }
    }

    # 显示已安装的 skills
    Write-Host ""
    Write-Info "已安装的 Skills:"
    Write-Host "─────────────────────────────────────────"

    Get-ChildItem -Path $SkillsDir -Directory | ForEach-Object {
        $SkillFile = Join-Path $_.FullName "SKILL.md"
        if (Test-Path $SkillFile) {
            $SkillName = $_.Name
            Write-Host "  • $SkillName" -ForegroundColor White

            # 提取 description
            $Content = Get-Content $SkillFile -Raw
            if ($Content -match 'description:\s*(.+)') {
                $Desc = $Matches[1].Trim()
                Write-Host "    $Desc" -ForegroundColor Gray
            }
        }
    }

    Write-Host "─────────────────────────────────────────"
    Write-Host ""
    Write-Info "请重启 Claude Code 以加载新的 Skills"

    # 清理
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Info "安装完成!"
}

Main

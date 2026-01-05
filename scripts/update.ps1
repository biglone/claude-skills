# Claude Skills 更新脚本 (Windows PowerShell)
# 强制更新所有 skills（覆盖已存在的）

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:CLAUDE_SKILLS_REPO) { $env:CLAUDE_SKILLS_REPO } else { "https://github.com/biglone/claude-skills.git" }
$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$TempDir = Join-Path $env:TEMP "claude-skills-$(Get-Random)"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Claude Skills 更新程序            ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # 检查 Git
    try {
        git --version | Out-Null
    } catch {
        Write-Err "Git 未安装"
        exit 1
    }

    # 创建目录
    if (-not (Test-Path $SkillsDir)) {
        New-Item -ItemType Directory -Path $SkillsDir -Force | Out-Null
    }

    # 克隆仓库
    Write-Info "获取最新 skills..."
    try {
        git clone --depth 1 $RepoUrl $TempDir 2>$null
    } catch {
        Write-Err "克隆仓库失败"
        exit 1
    }

    # 更新 skills
    $SourceDir = Join-Path $TempDir "skills"

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $TargetDir = Join-Path $SkillsDir $SkillName

        if (Test-Path $TargetDir) {
            Remove-Item -Path $TargetDir -Recurse -Force
            Write-Info "更新: $SkillName"
        } else {
            Write-Info "新增: $SkillName"
        }
        Copy-Item -Path $_.FullName -Destination $SkillsDir -Recurse
    }

    # 清理
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Info "更新完成! 请重启 Claude Code"
}

Main

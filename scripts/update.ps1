# AI Coding Skills 更新脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenAI Codex CLI

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:SKILLS_REPO) { $env:SKILLS_REPO } else { "https://github.com/biglone/claude-skills.git" }
$ClaudeSkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$CodexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"
$ClaudeWorkflowsDir = Join-Path $env:USERPROFILE ".claude\workflows"
$CodexWorkflowsDir = Join-Path $env:USERPROFILE ".codex\workflows"
$TempDir = Join-Path $env:TEMP "ai-skills-$(Get-Random)"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Select-Target {
    if ($env:UPDATE_TARGET) {
        return $env:UPDATE_TARGET
    }

    Write-Host ""
    Write-Host "请选择更新目标:" -ForegroundColor Cyan
    Write-Host "  1) Claude Code"
    Write-Host "  2) OpenAI Codex CLI"
    Write-Host "  3) 两者都更新"
    Write-Host ""

    $choice = Read-Host "请输入选项 [1-3] (默认: 3)"

    switch ($choice) {
        "1" { return "claude" }
        "2" { return "codex" }
        "3" { return "both" }
        "" { return "both" }
        default { return "both" }
    }
}

function Update-SkillsInDir {
    param($TargetDir, $TargetName, $SourceDir)

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $SkillTarget = Join-Path $TargetDir $SkillName

        if (Test-Path $SkillTarget) {
            Remove-Item -Path $SkillTarget -Recurse -Force
            Write-Info "[$TargetName] 更新: $SkillName"
        } else {
            Write-Info "[$TargetName] 新增: $SkillName"
        }
        Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
    }
}

function Update-WorkflowsInDir {
    param($TargetDir, $TargetName, $SourceDir)

    if (-not (Test-Path $SourceDir)) {
        Write-Warn "workflows 目录不存在，跳过"
        return
    }

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $WorkflowName = $_.Name
        $WorkflowTarget = Join-Path $TargetDir $WorkflowName

        if (Test-Path $WorkflowTarget) {
            Remove-Item -Path $WorkflowTarget -Recurse -Force
            Write-Info "[$TargetName] 更新 workflow: $WorkflowName"
        } else {
            Write-Info "[$TargetName] 新增 workflow: $WorkflowName"
        }
        Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
    }
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     AI Coding Skills 更新程序             ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # 检查 Git
    try {
        git --version | Out-Null
    } catch {
        Write-Err "Git 未安装"
        exit 1
    }

    $Target = Select-Target

    Write-Info "获取最新 skills..."
    try {
        git clone --depth 1 $RepoUrl $TempDir 2>$null
    } catch {
        Write-Err "克隆仓库失败"
        exit 1
    }

    $SourceDir = Join-Path $TempDir "skills"
    $WorkflowsSourceDir = Join-Path $TempDir "workflows"

    if ($Target -eq "claude" -or $Target -eq "both") {
        Update-SkillsInDir -TargetDir $ClaudeSkillsDir -TargetName "Claude Code" -SourceDir $SourceDir
        Update-WorkflowsInDir -TargetDir $ClaudeWorkflowsDir -TargetName "Claude Code" -SourceDir $WorkflowsSourceDir
    }

    if ($Target -eq "codex" -or $Target -eq "both") {
        Update-SkillsInDir -TargetDir $CodexSkillsDir -TargetName "Codex CLI" -SourceDir $SourceDir
        Update-WorkflowsInDir -TargetDir $CodexWorkflowsDir -TargetName "Codex CLI" -SourceDir $WorkflowsSourceDir
    }

    # 清理
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Info "更新完成! 请重启对应的 AI 编程工具"
}

Main

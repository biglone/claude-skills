# AI Coding Skills 安装脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenAI Codex CLI
# 用法: irm https://raw.githubusercontent.com/biglone/claude-skills/main/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"

# 配置
$RepoUrl = if ($env:SKILLS_REPO) { $env:SKILLS_REPO } else { "https://github.com/biglone/claude-skills.git" }
$ClaudeSkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$CodexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"
$ClaudeWorkflowsDir = Join-Path $env:USERPROFILE ".claude\workflows"
$CodexWorkflowsDir = Join-Path $env:USERPROFILE ".codex\workflows"
$TempDir = Join-Path $env:TEMP "ai-skills-$(Get-Random)"
$Script:InstalledSkills = @{
    "Claude Code" = New-Object System.Collections.Generic.List[string]
    "Codex CLI"   = New-Object System.Collections.Generic.List[string]
}

# 更新模式 (ask, skip, force)
$UpdateMode = if ($env:UPDATE_MODE) { $env:UPDATE_MODE } else { "ask" }

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

function Select-Target {
    if ($env:INSTALL_TARGET) {
        return $env:INSTALL_TARGET
    }

    Write-Host ""
    Write-Host "请选择安装目标:" -ForegroundColor Cyan
    Write-Host "  1) Claude Code"
    Write-Host "  2) OpenAI Codex CLI"
    Write-Host "  3) 两者都安装"
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

function Test-ShouldUpdate {
    param($SkillName, $TargetName)

    if ($UpdateMode -eq "skip") {
        return $false
    } elseif ($UpdateMode -eq "force") {
        return $true
    }

    # ask 模式：询问用户
    Write-Host ""
    $answer = Read-Host "[$TargetName] Skill '$SkillName' 已存在，是否更新? [y/N]"

    if ($answer -match "^[Yy]") {
        return $true
    }
    return $false
}

function Install-SkillsToDir {
    param($TargetDir, $TargetName, $SourceDir)

    if (-not (Test-Path $TargetDir)) {
        Write-Info "创建 $TargetName skills 目录: $TargetDir"
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Write-Info "安装 skills 到 $TargetName..."

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $SkillName = $_.Name
        $SkillTarget = Join-Path $TargetDir $SkillName

        if (Test-Path $SkillTarget) {
            if (Test-ShouldUpdate -SkillName $SkillName -TargetName $TargetName) {
                Remove-Item -Path $SkillTarget -Recurse -Force
                Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
                $Script:InstalledSkills[$TargetName].Add($SkillName)
                Write-Info "[$TargetName] 已更新: $SkillName"
            } else {
                Write-Warn "[$TargetName] 跳过: $SkillName"
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
            $Script:InstalledSkills[$TargetName].Add($SkillName)
            Write-Info "[$TargetName] 已安装: $SkillName"
        }
    }
}

function Install-WorkflowsToDir {
    param($TargetDir, $TargetName, $SourceDir)

    if (-not (Test-Path $SourceDir)) {
        Write-Warn "workflows 目录不存在，跳过"
        return
    }

    if (-not (Test-Path $TargetDir)) {
        Write-Info "创建 $TargetName workflows 目录: $TargetDir"
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    Write-Info "安装 workflows 到 $TargetName..."

    Get-ChildItem -Path $SourceDir -Directory | ForEach-Object {
        $WorkflowName = $_.Name
        $WorkflowTarget = Join-Path $TargetDir $WorkflowName

        if (Test-Path $WorkflowTarget) {
            if (Test-ShouldUpdate -SkillName $WorkflowName -TargetName $TargetName) {
                Remove-Item -Path $WorkflowTarget -Recurse -Force
                Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
                Write-Info "[$TargetName] 已更新 workflow: $WorkflowName"
            } else {
                Write-Warn "[$TargetName] 跳过 workflow: $WorkflowName"
            }
        } else {
            Copy-Item -Path $_.FullName -Destination $TargetDir -Recurse
            Write-Info "[$TargetName] 已安装 workflow: $WorkflowName"
        }
    }
}

function Show-Installed {
    param($SkillsDir, $Name)

    if (-not (Test-Path $SkillsDir)) { return }

    Write-Host ""
    Write-Info "$Name 本次安装/更新的 Skills:"
    Write-Host "─────────────────────────────────────────"

    $Changed = $Script:InstalledSkills[$Name] | Sort-Object -Unique
    if (-not $Changed -or $Changed.Count -eq 0) {
        Write-Host "  (无变更)" -ForegroundColor DarkGray
        Write-Host "─────────────────────────────────────────"
        return
    }

    $Changed | ForEach-Object {
        $SkillName = $_
        $SkillPath = Join-Path $SkillsDir $SkillName
        $SkillFile = Join-Path $SkillPath "SKILL.md"
        if (Test-Path $SkillFile) {
            Write-Host "  • $SkillName" -ForegroundColor White

            $Content = Get-Content $SkillFile -Raw
            if ($Content -match 'description:\s*(.+)') {
                $Desc = $Matches[1].Trim()
                Write-Host "    $Desc" -ForegroundColor Gray
            }
        }
    }

    Write-Host "─────────────────────────────────────────"
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     AI Coding Skills 安装程序             ║" -ForegroundColor Cyan
    Write-Host "║     支持 Claude Code / Codex CLI          ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    # 检查 Git
    if (-not (Test-Git)) {
        Write-Err "Git 未安装，请先安装 Git"
        exit 1
    }

    # 选择目标
    $Target = Select-Target

    # 克隆仓库
    Write-Info "克隆 skills 仓库..."
    try {
        git clone --depth 1 $RepoUrl $TempDir 2>$null
    } catch {
        Write-Err "克隆仓库失败，请检查仓库地址: $RepoUrl"
        exit 1
    }

    $SourceDir = Join-Path $TempDir "skills"
    $WorkflowsSourceDir = Join-Path $TempDir "workflows"

    if (-not (Test-Path $SourceDir)) {
        Write-Err "skills 目录不存在"
        exit 1
    }

    # 安装 skills
    if ($Target -eq "claude" -or $Target -eq "both") {
        Install-SkillsToDir -TargetDir $ClaudeSkillsDir -TargetName "Claude Code" -SourceDir $SourceDir
        Install-WorkflowsToDir -TargetDir $ClaudeWorkflowsDir -TargetName "Claude Code" -SourceDir $WorkflowsSourceDir
    }

    if ($Target -eq "codex" -or $Target -eq "both") {
        Install-SkillsToDir -TargetDir $CodexSkillsDir -TargetName "Codex CLI" -SourceDir $SourceDir
        Install-WorkflowsToDir -TargetDir $CodexWorkflowsDir -TargetName "Codex CLI" -SourceDir $WorkflowsSourceDir
    }

    # 显示已安装
    if ($Target -eq "claude" -or $Target -eq "both") {
        Show-Installed -SkillsDir $ClaudeSkillsDir -Name "Claude Code"
    }

    if ($Target -eq "codex" -or $Target -eq "both") {
        Show-Installed -SkillsDir $CodexSkillsDir -Name "Codex CLI"
    }

    # 清理
    Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Info "安装完成! 请重启对应的 AI 编程工具以加载 Skills"
}

Main

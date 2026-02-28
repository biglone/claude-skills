# AI Coding Skills 更新脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenAI Codex CLI

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:SKILLS_REPO) { $env:SKILLS_REPO } else { "https://github.com/biglone/agent-skills.git" }
$SkillsRef = if ($env:SKILLS_REF) { $env:SKILLS_REF } else { "main" }
$ClaudeSkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$CodexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"
$ClaudeWorkflowsDir = Join-Path $env:USERPROFILE ".claude\workflows"
$CodexWorkflowsDir = Join-Path $env:USERPROFILE ".codex\workflows"
$TempDir = Join-Path $env:TEMP "ai-skills-$(Get-Random)"
$PruneMode = if ($env:PRUNE_MODE) { $env:PRUNE_MODE.ToLower() } else { "off" }  # on/off
$DebugMode = ($env:DEBUG -eq "1" -or $env:DEBUG -eq "true")
$Script:SkillsManifest = @()
$Script:WorkflowsManifest = @()

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-DebugInfo { param($Message) if ($DebugMode) { Write-Host "[DEBUG] $Message" -ForegroundColor Cyan } }

function Get-ManifestEntriesFromFile {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "manifest 不存在: $Path"
    }

    $Entries = @()
    foreach ($Line in (Get-Content -Path $Path -Encoding UTF8)) {
        $Item = $Line.Trim()
        if (-not $Item) { continue }
        if ($Item.StartsWith("#")) { continue }
        $Entries += $Item
    }
    return $Entries
}

function Set-Manifests {
    $SkillsManifestFile = Join-Path $TempDir "scripts\manifest\skills.txt"
    $WorkflowsManifestFile = Join-Path $TempDir "scripts\manifest\workflows.txt"

    $Script:SkillsManifest = Get-ManifestEntriesFromFile -Path $SkillsManifestFile
    if ($Script:SkillsManifest.Count -eq 0) {
        throw "skills manifest 为空"
    }

    if (Test-Path $WorkflowsManifestFile) {
        $Script:WorkflowsManifest = Get-ManifestEntriesFromFile -Path $WorkflowsManifestFile
    } else {
        Write-Warn "workflows manifest 不存在，跳过 workflows 更新"
        $Script:WorkflowsManifest = @()
    }
}

function Test-ManifestContains {
    param([string[]]$Manifest, [string]$Name)
    return $Manifest -contains $Name
}

function Resolve-UpdateTargetFromEnv {
    if ([string]::IsNullOrWhiteSpace($env:UPDATE_TARGET)) {
        return $null
    }

    $Target = $env:UPDATE_TARGET.Trim().ToLowerInvariant()
    switch ($Target) {
        "claude" { return "claude" }
        "codex" { return "codex" }
        "both" { return "both" }
        default { throw "UPDATE_TARGET 无效: '$($env:UPDATE_TARGET)'。可选值: claude / codex / both" }
    }
}

function Prune-RemovedDirs {
    param($TargetDir, [string[]]$Manifest, $TargetName, $ItemLabel)

    if (-not (Test-Path $TargetDir)) { return }

    Get-ChildItem -Path $TargetDir -Directory | ForEach-Object {
        $Name = $_.Name
        if (-not (Test-ManifestContains -Manifest $Manifest -Name $Name)) {
            Remove-Item -Path $_.FullName -Recurse -Force
            Write-Info "[$TargetName] 清理已下线 ${ItemLabel}: $Name"
        }
    }
}

function Select-Target {
    $TargetFromEnv = Resolve-UpdateTargetFromEnv
    if ($TargetFromEnv) {
        return $TargetFromEnv
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

    foreach ($SkillName in $Script:SkillsManifest) {
        $SkillSource = Join-Path $SourceDir $SkillName
        if (-not (Test-Path $SkillSource)) {
            Write-Warn "[$TargetName] manifest 中的 skill 不存在，跳过: $SkillName"
            continue
        }

        $SkillTarget = Join-Path $TargetDir $SkillName
        if (Test-Path $SkillTarget) {
            Remove-Item -Path $SkillTarget -Recurse -Force
            Write-Info "[$TargetName] 更新: $SkillName"
        } else {
            Write-Info "[$TargetName] 新增: $SkillName"
        }
        Copy-Item -Path $SkillSource -Destination $TargetDir -Recurse
    }

    if ($PruneMode -eq "on") {
        Prune-RemovedDirs -TargetDir $TargetDir -Manifest $Script:SkillsManifest -TargetName $TargetName -ItemLabel "skill"
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

    if ($Script:WorkflowsManifest.Count -eq 0) {
        Write-Warn "workflows manifest 为空，跳过"
        return
    }

    foreach ($WorkflowName in $Script:WorkflowsManifest) {
        $WorkflowSource = Join-Path $SourceDir $WorkflowName
        if (-not (Test-Path $WorkflowSource)) {
            Write-Warn "[$TargetName] manifest 中的 workflow 不存在，跳过: $WorkflowName"
            continue
        }

        $WorkflowTarget = Join-Path $TargetDir $WorkflowName
        if (Test-Path $WorkflowTarget) {
            Remove-Item -Path $WorkflowTarget -Recurse -Force
            Write-Info "[$TargetName] 更新 workflow: $WorkflowName"
        } else {
            Write-Info "[$TargetName] 新增 workflow: $WorkflowName"
        }
        Copy-Item -Path $WorkflowSource -Destination $TargetDir -Recurse
    }

    if ($PruneMode -eq "on") {
        Prune-RemovedDirs -TargetDir $TargetDir -Manifest $Script:WorkflowsManifest -TargetName $TargetName -ItemLabel "workflow"
    }
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     AI Coding Skills 更新程序             ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $Succeeded = $false

    try {
        # 检查 Git
        try {
            git --version | Out-Null
        } catch {
            throw "Git 未安装"
        }

        $Target = Select-Target

        if ($PruneMode -ne "on" -and $PruneMode -ne "off") {
            Write-Warn "PRUNE_MODE 仅支持 on/off，当前为 '$PruneMode'，已自动降级为 off"
            $script:PruneMode = "off"
        }

        Write-Info "获取最新 skills..."
        Write-DebugInfo "clone source: $RepoUrl"
        Write-DebugInfo "clone ref: $SkillsRef"
        Write-DebugInfo "clone target: $TempDir"
        try {
            git clone --depth 1 --branch $SkillsRef $RepoUrl $TempDir
        } catch {
            throw "克隆仓库失败"
        }

        $SourceDir = Join-Path $TempDir "skills"
        $WorkflowsSourceDir = Join-Path $TempDir "workflows"
        Set-Manifests

        if ($Target -eq "claude" -or $Target -eq "both") {
            Update-SkillsInDir -TargetDir $ClaudeSkillsDir -TargetName "Claude Code" -SourceDir $SourceDir
            Update-WorkflowsInDir -TargetDir $ClaudeWorkflowsDir -TargetName "Claude Code" -SourceDir $WorkflowsSourceDir
        }

        if ($Target -eq "codex" -or $Target -eq "both") {
            Update-SkillsInDir -TargetDir $CodexSkillsDir -TargetName "Codex CLI" -SourceDir $SourceDir
            Update-WorkflowsInDir -TargetDir $CodexWorkflowsDir -TargetName "Codex CLI" -SourceDir $WorkflowsSourceDir
        }

        $Succeeded = $true
    } finally {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($Succeeded) {
        Write-Host ""
        Write-Info "更新完成! 请重启对应的 AI 编程工具"
    }
}

try {
    Main
} catch {
    Write-Err $_.Exception.Message
    exit 1
}

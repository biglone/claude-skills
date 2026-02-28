# AI Coding Skills 安装脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenAI Codex CLI
# 用法: irm https://raw.githubusercontent.com/biglone/agent-skills/main/scripts/install.ps1 | iex

$ErrorActionPreference = "Stop"

# 配置
$RepoUrl = if ($env:SKILLS_REPO) { $env:SKILLS_REPO } else { "https://github.com/biglone/agent-skills.git" }
$SkillsRef = if ($env:SKILLS_REF) { $env:SKILLS_REF } else { "main" }
$ClaudeSkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$CodexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"
$ClaudeWorkflowsDir = Join-Path $env:USERPROFILE ".claude\workflows"
$CodexWorkflowsDir = Join-Path $env:USERPROFILE ".codex\workflows"
$TempDir = Join-Path $env:TEMP "ai-skills-$(Get-Random)"
$Script:InstalledSkills = @{
    "Claude Code" = New-Object System.Collections.Generic.List[string]
    "Codex CLI"   = New-Object System.Collections.Generic.List[string]
}
$DebugMode = ($env:DEBUG -eq "1" -or $env:DEBUG -eq "true")
$NonInteractive = ($env:NON_INTERACTIVE -eq "1" -or $env:NON_INTERACTIVE -eq "true")
$DryRun = ($env:DRY_RUN -eq "1" -or $env:DRY_RUN -eq "true")
$CodexAutoUpdateSetup = if ($env:CODEX_AUTO_UPDATE_SETUP) { $env:CODEX_AUTO_UPDATE_SETUP } else { "on" }
$CodexAutoUpdateRepo = if ($env:CODEX_AUTO_UPDATE_REPO) { $env:CODEX_AUTO_UPDATE_REPO } else { "" }
$CodexAutoUpdateBranch = if ($env:CODEX_AUTO_UPDATE_BRANCH) { $env:CODEX_AUTO_UPDATE_BRANCH } else { $SkillsRef }
$CodexLocalVersionFile = Join-Path $env:USERPROFILE ".codex\.skills_version"
$CodexAutoUpdateLoader = Join-Path $env:USERPROFILE ".codex\codex-skills-auto-update.ps1"
$Script:AskFallbackWarned = $false
$Script:SkillsManifest = @()
$Script:WorkflowsManifest = @()

# 更新模式 (ask, skip, force)
$UpdateMode = if ($env:UPDATE_MODE) { $env:UPDATE_MODE.Trim().ToLowerInvariant() } else { "force" }

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err { param($Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }
function Write-DebugInfo { param($Message) if ($DebugMode) { Write-Host "[DEBUG] $Message" -ForegroundColor Cyan } }

function Show-Usage {
    @"
Usage: install.ps1 [options]

Options:
  --non-interactive   Disable prompts and use defaults/env values
  --dry-run           Print planned actions without writing target dirs
  -h, --help          Show this help
"@ | Write-Host
}

function Parse-Args {
    param([string[]]$ScriptArgs)

    foreach ($Arg in $ScriptArgs) {
        switch ($Arg.ToLowerInvariant()) {
            "--non-interactive" { $script:NonInteractive = $true }
            "--dry-run" { $script:DryRun = $true }
            "-h" {
                Show-Usage
                exit 0
            }
            "--help" {
                Show-Usage
                exit 0
            }
            default {
                throw "未知参数: $Arg"
            }
        }
    }
}

function Test-InteractiveSession {
    try {
        return (-not [Console]::IsInputRedirected) -and (-not [Console]::IsOutputRedirected)
    } catch {
        return $false
    }
}

function Resolve-UpdateMode {
    param([string]$Mode)

    $Normalized = if ([string]::IsNullOrWhiteSpace($Mode)) { "force" } else { $Mode.Trim().ToLowerInvariant() }
    if ($Normalized -notin @("ask", "skip", "force")) {
        throw "UPDATE_MODE 无效: '$Mode'。可选值: ask / skip / force"
    }

    return $Normalized
}

function Resolve-InstallTargetFromEnv {
    if ([string]::IsNullOrWhiteSpace($env:INSTALL_TARGET)) {
        return $null
    }

    return Resolve-InstallTargetValue -Value $env:INSTALL_TARGET
}

function Resolve-InstallTargetValue {
    param([string]$Value)

    $Target = $Value.Trim().ToLowerInvariant()
    switch ($Target) {
        "claude" { return "claude" }
        "codex" { return "codex" }
        "both" { return "both" }
        default { throw "INSTALL_TARGET 无效: '$Value'。可选值: claude / codex / both" }
    }
}

function Resolve-RepoSlug {
    param([string]$RepoUrlValue)

    if ([string]::IsNullOrWhiteSpace($RepoUrlValue)) {
        return $null
    }

    $Value = $RepoUrlValue.Trim()
    if ($Value -match '^https://github\.com/([^/]+/[^/]+?)(?:\.git)?/?$') {
        return $Matches[1]
    }
    if ($Value -match '^git@github\.com:([^/]+/[^/]+?)(?:\.git)?$') {
        return $Matches[1]
    }
    if ($Value -match '^ssh://git@github\.com/([^/]+/[^/]+?)(?:\.git)?/?$') {
        return $Matches[1]
    }

    return $null
}

function Get-ManifestEntries {
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
    $SkillsManifestPath = Join-Path $TempDir "scripts\manifest\skills.txt"
    $WorkflowsManifestPath = Join-Path $TempDir "scripts\manifest\workflows.txt"

    $Script:SkillsManifest = Get-ManifestEntries -Path $SkillsManifestPath
    if ($Script:SkillsManifest.Count -eq 0) {
        throw "skills manifest 为空"
    }

    if (Test-Path $WorkflowsManifestPath) {
        $Script:WorkflowsManifest = Get-ManifestEntries -Path $WorkflowsManifestPath
    } else {
        Write-Warn "workflows manifest 不存在，跳过 workflows 安装"
        $Script:WorkflowsManifest = @()
    }
}

function Is-Truthy {
    param([string]$Value)
    if ([string]::IsNullOrWhiteSpace($Value)) { return $false }
    switch ($Value.Trim().ToLowerInvariant()) {
        "1" { return $true }
        "true" { return $true }
        "yes" { return $true }
        "on" { return $true }
        default { return $false }
    }
}

function Sync-CodexLocalVersion {
    $VersionFile = Join-Path $TempDir "scripts\manifest\version.txt"
    $Version = ""
    if (Test-Path $VersionFile) {
        $Version = (Get-Content -Path $VersionFile -Raw -Encoding UTF8).Trim()
    }
    if (-not $Version) {
        try {
            $Version = (git -C $TempDir rev-parse --short=12 HEAD).Trim()
        } catch {
            $Version = ""
        }
    }
    if (-not $Version) {
        Write-Warn "[Codex CLI] 无法写入本地 skills 版本（version/commit 均不可用）"
        return
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $CodexLocalVersionFile) -Force | Out-Null
    Set-Content -Path $CodexLocalVersionFile -Value $Version -Encoding UTF8
    Write-Info "[Codex CLI] 已写入本地 skills 版本: $Version"
}

function Upsert-ProfileSourceBlock {
    param([string]$ProfilePath)

    $StartMarker = "# >>> agent-skills codex auto-update >>>"
    $EndMarker = "# <<< agent-skills codex auto-update <<<"
    $SourceLine = '. "$env:USERPROFILE\.codex\codex-skills-auto-update.ps1"'

    New-Item -ItemType Directory -Path (Split-Path -Parent $ProfilePath) -Force | Out-Null
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
    }

    $Content = Get-Content -Path $ProfilePath -Raw -Encoding UTF8
    $Pattern = [Regex]::Escape($StartMarker) + '.*?' + [Regex]::Escape($EndMarker)
    $Block = "$StartMarker`r`n$SourceLine`r`n$EndMarker"

    if ($Content -match $Pattern) {
        $NewContent = [Regex]::Replace($Content, $Pattern, $Block, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    } elseif ([string]::IsNullOrWhiteSpace($Content)) {
        $NewContent = "$Block`r`n"
    } else {
        $NewContent = $Content.TrimEnd() + "`r`n`r`n" + $Block + "`r`n"
    }
    Set-Content -Path $ProfilePath -Value $NewContent -Encoding UTF8
}

function Configure-CodexAutoUpdateLauncher {
    if (-not (Is-Truthy $CodexAutoUpdateSetup)) {
        Write-Info "[Codex CLI] 跳过自动更新配置（CODEX_AUTO_UPDATE_SETUP=$CodexAutoUpdateSetup）"
        return
    }

    $RepoSlug = if ($CodexAutoUpdateRepo) { $CodexAutoUpdateRepo } else { Resolve-RepoSlug -RepoUrlValue $RepoUrl }
    if (-not $RepoSlug) {
        $RepoSlug = "biglone/agent-skills"
        Write-Warn "[Codex CLI] 无法从 SKILLS_REPO 推断 GitHub 仓库，已回退为: $RepoSlug"
    }

    New-Item -ItemType Directory -Path (Split-Path -Parent $CodexAutoUpdateLoader) -Force | Out-Null
    $LoaderContent = @"
# Auto-generated by agent-skills/scripts/install.ps1
# Set CODEX_SKILLS_AUTO_UPDATE=0 to disable auto update checks.
if (`$env:CODEX_SKILLS_AUTO_UPDATE -eq "0") {
    return
}

`$repo = "$RepoSlug"
`$ref = "$CodexAutoUpdateBranch"
`$versionUrl = "https://raw.githubusercontent.com/`$repo/`$ref/scripts/manifest/version.txt"
`$installUrl = "https://raw.githubusercontent.com/`$repo/`$ref/scripts/install.ps1"
`$localVersionFile = "$CodexLocalVersionFile"

try {
    `$remoteVersion = (Invoke-RestMethod -Uri `$versionUrl -TimeoutSec 8).ToString().Trim()
} catch {
    `$remoteVersion = ""
}
if (-not `$remoteVersion) {
    return
}

`$localVersion = ""
if (Test-Path `$localVersionFile) {
    `$localVersion = (Get-Content -Path `$localVersionFile -Raw -Encoding UTF8).Trim()
}

if (`$remoteVersion -ne `$localVersion) {
    Write-Host "[skills] update `$localVersion -> `$remoteVersion"
    `$oldUpdateMode = `$env:UPDATE_MODE
    `$oldInstallTarget = `$env:INSTALL_TARGET
    `$oldAutoSetup = `$env:CODEX_AUTO_UPDATE_SETUP
    `$oldSkillsRef = `$env:SKILLS_REF
    try {
        `$env:UPDATE_MODE = "force"
        `$env:INSTALL_TARGET = "codex"
        `$env:CODEX_AUTO_UPDATE_SETUP = "off"
        `$env:SKILLS_REF = `$ref
        Invoke-RestMethod -Uri `$installUrl -TimeoutSec 20 | Invoke-Expression
        Set-Content -Path `$localVersionFile -Value `$remoteVersion -Encoding UTF8
    } catch {
        Write-Host "[skills] auto-update failed, continue launching codex" -ForegroundColor Yellow
    } finally {
        if (`$null -eq `$oldUpdateMode) { Remove-Item Env:UPDATE_MODE -ErrorAction SilentlyContinue } else { `$env:UPDATE_MODE = `$oldUpdateMode }
        if (`$null -eq `$oldInstallTarget) { Remove-Item Env:INSTALL_TARGET -ErrorAction SilentlyContinue } else { `$env:INSTALL_TARGET = `$oldInstallTarget }
        if (`$null -eq `$oldAutoSetup) { Remove-Item Env:CODEX_AUTO_UPDATE_SETUP -ErrorAction SilentlyContinue } else { `$env:CODEX_AUTO_UPDATE_SETUP = `$oldAutoSetup }
        if (`$null -eq `$oldSkillsRef) { Remove-Item Env:SKILLS_REF -ErrorAction SilentlyContinue } else { `$env:SKILLS_REF = `$oldSkillsRef }
    }
}
"@
    Set-Content -Path $CodexAutoUpdateLoader -Value $LoaderContent -Encoding UTF8

    $ProfileCandidates = @(
        $PROFILE.CurrentUserCurrentHost,
        Join-Path $env:USERPROFILE "Documents\PowerShell\Microsoft.PowerShell_profile.ps1",
        Join-Path $env:USERPROFILE "Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
    ) | Select-Object -Unique

    foreach ($ProfilePath in $ProfileCandidates) {
        Upsert-ProfileSourceBlock -ProfilePath $ProfilePath
    }

    Write-Info "[Codex CLI] 已配置 PowerShell 启动时检查 skills 更新"
    Write-Info "[Codex CLI] 配置文件: $CodexAutoUpdateLoader"
}

function Test-Git {
    try {
        git --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Select-Target {
    $TargetFromEnv = Resolve-InstallTargetFromEnv
    if ($TargetFromEnv) {
        return $TargetFromEnv
    }

    if ($NonInteractive) {
        Write-Info "非交互模式：默认安装到两者（INSTALL_TARGET=both）"
        return "both"
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

    # ask 模式：仅在可交互会话中询问，避免 CI / 重定向环境卡住
    if ($NonInteractive -or -not (Test-InteractiveSession)) {
        if (-not $Script:AskFallbackWarned) {
            Write-Warn "非交互环境且 UPDATE_MODE=ask，将按 force 处理"
            $Script:AskFallbackWarned = $true
        }
        return $true
    }

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
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
    }

    Write-Info "安装 skills 到 $TargetName..."

    foreach ($SkillName in $Script:SkillsManifest) {
        $SkillSource = Join-Path $SourceDir $SkillName
        if (-not (Test-Path $SkillSource)) {
            Write-Warn "[$TargetName] manifest 中的 skill 不存在，跳过: $SkillName"
            continue
        }

        $SkillTarget = Join-Path $TargetDir $SkillName

        if (Test-Path $SkillTarget) {
            if (Test-ShouldUpdate -SkillName $SkillName -TargetName $TargetName) {
                if ($DryRun) {
                    Write-Info "[DRY-RUN][$TargetName] 将更新: $SkillName"
                } else {
                    Remove-Item -Path $SkillTarget -Recurse -Force
                    Copy-Item -Path $SkillSource -Destination $TargetDir -Recurse
                    Write-Info "[$TargetName] 已更新: $SkillName"
                }
                $Script:InstalledSkills[$TargetName].Add($SkillName)
            } else {
                Write-Warn "[$TargetName] 跳过: $SkillName"
            }
        } else {
            if ($DryRun) {
                Write-Info "[DRY-RUN][$TargetName] 将安装: $SkillName"
            } else {
                Copy-Item -Path $SkillSource -Destination $TargetDir -Recurse
                Write-Info "[$TargetName] 已安装: $SkillName"
            }
            $Script:InstalledSkills[$TargetName].Add($SkillName)
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
        if (-not $DryRun) {
            New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
        }
    }

    Write-Info "安装 workflows 到 $TargetName..."

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
            if (Test-ShouldUpdate -SkillName $WorkflowName -TargetName $TargetName) {
                if ($DryRun) {
                    Write-Info "[DRY-RUN][$TargetName] 将更新 workflow: $WorkflowName"
                } else {
                    Remove-Item -Path $WorkflowTarget -Recurse -Force
                    Copy-Item -Path $WorkflowSource -Destination $TargetDir -Recurse
                    Write-Info "[$TargetName] 已更新 workflow: $WorkflowName"
                }
            } else {
                Write-Warn "[$TargetName] 跳过 workflow: $WorkflowName"
            }
        } else {
            if ($DryRun) {
                Write-Info "[DRY-RUN][$TargetName] 将安装 workflow: $WorkflowName"
            } else {
                Copy-Item -Path $WorkflowSource -Destination $TargetDir -Recurse
                Write-Info "[$TargetName] 已安装 workflow: $WorkflowName"
            }
        }
    }
}

function Show-Installed {
    param($SkillsDir, $Name)

    if (-not (Test-Path $SkillsDir) -and -not $DryRun) { return }

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
        if ($DryRun) {
            Write-Host "  • $SkillName (planned)" -ForegroundColor White
            return
        }

        $SkillPath = Join-Path $SkillsDir $SkillName
        $SkillFile = Join-Path $SkillPath "SKILL.md"
        if (Test-Path $SkillFile) {
            Write-Host "  • $SkillName" -ForegroundColor White

            # SKILL.md 使用 UTF-8，Windows PowerShell 5.1 默认读取编码会导致中文乱码
            $Content = Get-Content $SkillFile -Raw -Encoding UTF8
            if ($Content -match 'description:\s*(.+)') {
                $Desc = $Matches[1].Trim()
                Write-Host "    $Desc" -ForegroundColor Gray
            }
        }
    }

    Write-Host "─────────────────────────────────────────"
}

function Main {
    param([string[]]$ScriptArgs)

    Parse-Args -ScriptArgs $ScriptArgs

    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     AI Coding Skills 安装程序             ║" -ForegroundColor Cyan
    Write-Host "║     支持 Claude Code / Codex CLI          ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    if ($DryRun) {
        Write-Info "已启用 dry-run：不会写入目标目录"
    }

    $Target = $null
    $Succeeded = $false

    try {
        # 校验并归一化更新策略
        $script:UpdateMode = Resolve-UpdateMode -Mode $UpdateMode

        # 检查 Git
        if (-not (Test-Git)) {
            throw "Git 未安装，请先安装 Git"
        }

        # 选择目标
        $Target = Select-Target

        # 克隆仓库
        Write-Info "克隆 skills 仓库..."
        Write-DebugInfo "clone source: $RepoUrl"
        Write-DebugInfo "clone ref: $SkillsRef"
        Write-DebugInfo "clone target: $TempDir"
        try {
            git clone --depth 1 --branch $SkillsRef $RepoUrl $TempDir
        } catch {
            throw "克隆仓库失败，请检查仓库地址/引用: $RepoUrl @ $SkillsRef"
        }

        $SourceDir = Join-Path $TempDir "skills"
        $WorkflowsSourceDir = Join-Path $TempDir "workflows"
        Set-Manifests

        if (-not (Test-Path $SourceDir)) {
            throw "skills 目录不存在"
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

        if ($Target -eq "codex" -or $Target -eq "both") {
            if ($DryRun) {
                Write-Info "[DRY-RUN] 跳过写入 Codex 本地版本与自动更新配置"
            } else {
                Sync-CodexLocalVersion
                Configure-CodexAutoUpdateLauncher
            }
        }

        $Succeeded = $true
    } finally {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    if ($Succeeded) {
        Write-Host ""
        Write-Info "安装完成! 请重启对应的 AI 编程工具以加载 Skills"
        if (-not $DryRun -and ($Target -eq "codex" -or $Target -eq "both")) {
            Write-Info "Codex 自动更新配置已写入 PowerShell profile，新终端会生效"
        }
    }
}

try {
    Main -ScriptArgs $args
} catch {
    Write-Err $_.Exception.Message
    exit 1
}

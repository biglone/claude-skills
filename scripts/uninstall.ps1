# AI Coding Skills 卸载脚本 (Windows PowerShell)
# 支持 Claude Code 和 OpenAI Codex CLI

$ErrorActionPreference = "Stop"

$ClaudeSkillsDir = Join-Path $env:USERPROFILE ".claude\skills"
$CodexSkillsDir = Join-Path $env:USERPROFILE ".codex\skills"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }

$SkillsToRemove = @(
    "code-reviewer"
    "commit-message"
    "security-audit"
    "code-explainer"
    "test-generator"
    "refactoring"
    "api-designer"
    "doc-generator"
    "performance-optimizer"
    "bug-finder"
    "regex-helper"
    "sql-helper"
    "git-helper"
    "changelog-generator"
    "pr-description"
    "dependency-analyzer"
    "i18n-helper"
    "migration-helper"
)

function Select-Target {
    if ($env:UNINSTALL_TARGET) {
        return $env:UNINSTALL_TARGET
    }

    Write-Host ""
    Write-Host "请选择卸载目标:" -ForegroundColor Cyan
    Write-Host "  1) Claude Code"
    Write-Host "  2) OpenAI Codex CLI"
    Write-Host "  3) 两者都卸载"
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

function Uninstall-FromDir {
    param($TargetDir, $TargetName)

    foreach ($Skill in $SkillsToRemove) {
        $SkillPath = Join-Path $TargetDir $Skill

        if (Test-Path $SkillPath) {
            Remove-Item -Path $SkillPath -Recurse -Force
            Write-Info "[$TargetName] 已卸载: $Skill"
        } else {
            Write-Warn "[$TargetName] Skill '$Skill' 不存在，跳过"
        }
    }
}

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     AI Coding Skills 卸载程序             ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    $Target = Select-Target

    if ($Target -eq "claude" -or $Target -eq "both") {
        Uninstall-FromDir -TargetDir $ClaudeSkillsDir -TargetName "Claude Code"
    }

    if ($Target -eq "codex" -or $Target -eq "both") {
        Uninstall-FromDir -TargetDir $CodexSkillsDir -TargetName "Codex CLI"
    }

    Write-Host ""
    Write-Info "卸载完成! 请重启对应的 AI 编程工具"
}

Main

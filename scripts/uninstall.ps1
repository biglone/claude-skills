# Claude Skills 卸载脚本 (Windows PowerShell)

$ErrorActionPreference = "Stop"

$SkillsDir = Join-Path $env:USERPROFILE ".claude\skills"

function Write-Info { param($Message) Write-Host "[INFO] $Message" -ForegroundColor Green }
function Write-Warn { param($Message) Write-Host "[WARN] $Message" -ForegroundColor Yellow }

# 要卸载的 skills 列表
$SkillsToRemove = @(
    "code-reviewer"
    "commit-message"
    "security-audit"
    "code-explainer"
    "test-generator"
)

function Main {
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     Claude Skills 卸载程序            ║" -ForegroundColor Cyan
    Write-Host "╚═══════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""

    foreach ($Skill in $SkillsToRemove) {
        $SkillPath = Join-Path $SkillsDir $Skill

        if (Test-Path $SkillPath) {
            Remove-Item -Path $SkillPath -Recurse -Force
            Write-Info "已卸载: $Skill"
        } else {
            Write-Warn "Skill '$Skill' 不存在，跳过"
        }
    }

    Write-Host ""
    Write-Info "卸载完成! 请重启 Claude Code"
}

Main

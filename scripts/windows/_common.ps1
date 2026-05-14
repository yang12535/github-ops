# Common helpers for github-ops Windows wrappers.
# Design note: This skill is consumed by AI agents. Agents are expected to
# resolve environment dependencies when they see a clear, actionable error.
# No probing, no fallback — hard errors with instructions.

$ErrorActionPreference = "Stop"

function Invoke-GitHubApi {
    param(
        [Parameter(Mandatory)][string]$Endpoint,
        [string]$Method = "GET",
        [string]$Data,
        [switch]$Paginate,
        [switch]$Compact,
        [string[]]$Field
    )

    $WindowsDir = Split-Path -Parent $PSCommandPath
    $ScriptsDir = Split-Path -Parent $WindowsDir
    $ApiScript  = Join-Path $ScriptsDir "gh-api.py"

    if (-not (Test-Path $ApiScript)) {
        Write-Host "[github-ops ERROR] Backend not found: $ApiScript" -ForegroundColor Red
        Write-Host "Repository may be incomplete or corrupted." -ForegroundColor Yellow
        exit 1
    }

    $pyArgs = @($Endpoint)
    if ($Method -ne "GET") { $pyArgs += @("-X", $Method) }
    if ($Data) { $pyArgs += @("-d", $Data) }
    if ($Paginate) { $pyArgs += "-p" }
    if ($Compact) { $pyArgs += "-c" }
    if ($Field) { foreach ($f in $Field) { $pyArgs += @("-f", $f) } }

    try {
        & python $ApiScript @pyArgs
    } catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "[github-ops ERROR] Python interpreter not found." -ForegroundColor Red
        Write-Host "  Command: python $ApiScript" -ForegroundColor Yellow
        Write-Host "  This skill requires Python 3.8+ on Windows." -ForegroundColor Yellow
        Write-Host "  Install: winget install Python.Python.3" -ForegroundColor Cyan
        exit 127
    } catch {
        Write-Host "[github-ops ERROR] $_" -ForegroundColor Red
        exit 1
    }

    exit $LASTEXITCODE
}

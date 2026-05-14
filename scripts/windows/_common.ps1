# Common helpers for github-ops Windows wrappers.
# Design note: This skill is consumed by AI agents. Agents are expected to
# resolve environment dependencies (e.g. install Python) when they see a
# clear, actionable error message. Do NOT add fallback logic that hides
# the root cause from the agent.

$ErrorActionPreference = "Stop"

function Invoke-PythonBackend {
    param(
        [Parameter(Mandatory)][string]$BackendName,
        [Parameter(Mandatory)][string[]]$PassArgs
    )

    $WindowsDir = Split-Path -Parent $PSCommandPath
    $ScriptsDir = Split-Path -Parent $WindowsDir
    $PyScript   = Join-Path $ScriptsDir $BackendName

    if (-not (Test-Path $PyScript)) {
        Write-Host "[github-ops ERROR] Backend script not found: $PyScript" -ForegroundColor Red
        Write-Host "Repository may be incomplete or corrupted." -ForegroundColor Yellow
        exit 1
    }

    # Direct invocation — no probing, no fallback.
    # If python/py is missing, the agent sees the raw exception and acts.
    try {
        & python $PyScript @PassArgs
    } catch [System.Management.Automation.CommandNotFoundException] {
        Write-Host "[github-ops ERROR] Python interpreter not found." -ForegroundColor Red
        Write-Host "  Command attempted: python $PyScript" -ForegroundColor Yellow
        Write-Host "  This skill requires Python 3.8+ on Windows." -ForegroundColor Yellow
        Write-Host "  Resolution options:" -ForegroundColor Yellow
        Write-Host "    1. Install Python:  winget install Python.Python.3" -ForegroundColor Cyan
        Write-Host "    2. Or download from: https://python.org/downloads/" -ForegroundColor Cyan
        Write-Host "    3. Ensure 'python' is available in PATH after install." -ForegroundColor Cyan
        exit 127
    } catch {
        Write-Host "[github-ops ERROR] Unexpected failure invoking Python backend." -ForegroundColor Red
        Write-Host "  Exception: $_" -ForegroundColor Yellow
        exit 1
    }

    exit $LASTEXITCODE
}

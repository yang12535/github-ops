# Common helpers for github-ops Windows wrappers.
# Design note: This skill is consumed by AI agents. Agents are expected to
# resolve environment dependencies when they see a clear, actionable error.
# No probing, no fallback — hard errors with instructions.

$ErrorActionPreference = "Stop"

function Get-GitHubToken {
    # Pre-flight auth check: try gh CLI first, then env vars, then token files.
    # Mirrors the fallback chain in scripts/gh-api.py get_token().
    try {
        $result = & gh auth token 2>$null
        if ($result) { return $result }
    } catch { }

    $token = $env:GITHUB_TOKEN
    if (-not $token) { $token = $env:GH_TOKEN }
    if ($token) { return $token }

    $fallbackPaths = @(
        (Join-Path $env:USERPROFILE ".github_token"),
        (Join-Path $env:USERPROFILE ".config\github-ops\token"),
        (Join-Path $env:USERPROFILE "github_token.txt")
    )
    foreach ($path in $fallbackPaths) {
        if (Test-Path $path) {
            # Security check: reject if group/others can read/write (Windows ACL-aware)
            $acl = Get-Acl $path -ErrorAction SilentlyContinue
            if ($acl) {
                $unsafe = $false
                foreach ($rule in $acl.Access) {
                    if ($rule.IdentityReference.Value -match "Users|Everyone|Authenticated Users|BUILTIN\\Users") {
                        if ($rule.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::Read) {
                            $unsafe = $true
                            break
                        }
                    }
                }
                if ($unsafe) {
                    Write-Host "[github-ops WARNING] Token file $path is readable by other users, skipping." -ForegroundColor Yellow
                    continue
                }
            }
            return Get-Content $path -Raw
        }
    }

    Write-Host "[github-ops ERROR] No GitHub token found." -ForegroundColor Red
    Write-Host "  1. Run:  gh auth login" -ForegroundColor Cyan
    Write-Host "  2. Or set env:  `$env:GITHUB_TOKEN = 'ghp_xxxxxxxx'" -ForegroundColor Cyan
    Write-Host "  3. Or create:  ~\.github_token  (user-readable only)" -ForegroundColor Cyan
    exit 1
}

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

    # Pre-flight: verify Python exists and meets version requirement.
    # Note: Get-Command may still find the Microsoft Store shim on PATH.
    # The actual shim rejection happens in the version-regex check below.
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonCmd) {
        Write-Host "[github-ops ERROR] Python interpreter not found." -ForegroundColor Red
        Write-Host "  This skill requires Python 3.8+ on Windows." -ForegroundColor Yellow
        Write-Host "  Install: winget install Python.Python.3" -ForegroundColor Cyan
        Write-Host "  Or download from: https://python.org/downloads/" -ForegroundColor Cyan
        exit 127
    }

    $verOutput = & python --version 2>&1
    if ($verOutput -notmatch "Python (\d+)\.(\d+)") {
        Write-Host "[github-ops ERROR] Unable to determine Python version: $verOutput" -ForegroundColor Red
        exit 1
    }
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    if ($major -lt 3 -or ($major -eq 3 -and $minor -lt 8)) {
        Write-Host "[github-ops ERROR] Python $major.$minor is too old. Python 3.8+ required." -ForegroundColor Red
        exit 1
    }

    # Pre-flight: resolve GitHub token and inject into environment so Python
    # backend does not need to shell out to gh CLI again.
    $token = Get-GitHubToken
    if ($token) { $env:GITHUB_TOKEN = $token }

    $pyArgs = @($Endpoint)
    if ($Method -ne "GET") { $pyArgs += @("-X", $Method) }
    if ($Data) { $pyArgs += @("-d", $Data) }
    if ($Paginate) { $pyArgs += "-p" }
    if ($Compact) { $pyArgs += "-c" }
    if ($Field) { foreach ($f in $Field) { $pyArgs += @("-f", $f) } }

    & python $ApiScript @pyArgs
    exit $LASTEXITCODE
}

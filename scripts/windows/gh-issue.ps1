#!/usr/bin/env pwsh
# Windows entrypoint for gh-issue — delegates to ../gh-api.py (Python).

param(
    [Parameter(Mandatory, Position = 0)][string]$Repo,
    [Parameter(Position = 1)]
    [ValidateSet("list", "view", "create", "close", "reopen", "comment")]
    [string]$Command = "list"
)

. $PSScriptRoot\_common.ps1

$Remaining = $args

switch ($Command) {
    "list" { Invoke-GitHubApi "repos/$Repo/issues" -Paginate }
    "view" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> view <number>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/issues/$num"
    }
    "create" {
        $title = $Remaining[0]
        if (-not $title) { Write-Error "Usage: gh-issue.ps1 <owner/repo> create <title> [--body <text>|--body-file <path>]"; exit 1 }
        $body = ""
        for ($i = 1; $i -lt $Remaining.Count; $i++) {
            if ($Remaining[$i] -eq "--body") {
                if (($i+1) -ge $Remaining.Count) { Write-Error "Usage: --body requires a value"; exit 1 }
                $body = $Remaining[$i+1]; $i++
            } elseif ($Remaining[$i] -eq "--body-file") {
                if (($i+1) -ge $Remaining.Count) { Write-Error "Usage: --body-file requires a path"; exit 1 }
                $bf = $Remaining[$i+1]
                if (-not (Test-Path $bf)) { Write-Error "Body file not found: $bf"; exit 1 }
                $body = Get-Content $bf -Raw -ErrorAction Stop; $i++
            } else {
                Write-Error "Unknown option: $($Remaining[$i])"; exit 1
            }
        }
        $payload = @{ title = $title }
        if ($body) { $payload.body = $body }
        $tmpFile = [System.IO.Path]::GetTempFileName()
        Write-Utf8NoBomFile -Path $tmpFile -Value ($payload | ConvertTo-Json -Compress -Depth 10)
        try {
            Invoke-GitHubApi "repos/$Repo/issues" -Method POST -Data "@$tmpFile"
        } finally {
            Remove-Item -Path $tmpFile -ErrorAction SilentlyContinue
        }
    }
    "close" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> close <number>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/issues/$num" -Method PATCH -Data '{"state":"closed"}'
    }
    "reopen" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> reopen <number>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/issues/$num" -Method PATCH -Data '{"state":"open"}'
    }
    "comment" {
        $num = $Remaining[0]
        $body = $Remaining[1]
        if (-not $num -or -not $body) { Write-Error "Usage: gh-issue.ps1 <owner/repo> comment <number> <body>"; exit 1 }
        $json = @{ body = $body } | ConvertTo-Json -Compress -Depth 10
        Invoke-GitHubApi "repos/$Repo/issues/$num/comments" -Method POST -Data $json
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Commands: list, view <n>, create <title>, close <n>, reopen <n>, comment <n> <body>"
        exit 1
    }
}

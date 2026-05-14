#!/usr/bin/env pwsh
# Windows entrypoint for gh-pr — delegates to ../gh-api.py (Python).

. $PSScriptRoot\_common.ps1

param(
    [Parameter(Mandatory, Position = 0)][string]$Repo,
    [Parameter(Position = 1)][string]$Command = "list"
)

$Remaining = $args

switch ($Command) {
    "list" { Invoke-GitHubApi "repos/$Repo/pulls" -Paginate }
    "view" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> view <number>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/pulls/$num"
    }
    "create" {
        if ($Remaining.Count -lt 3) { Write-Error "Usage: gh-pr.ps1 <owner/repo> create <title> <head> <base> [--body <text>|--body-file <path>]"; exit 1 }
        $title = $Remaining[0]
        $head = $Remaining[1]
        $base = $Remaining[2]
        $body = ""
        for ($i = 3; $i -lt $Remaining.Count; $i++) {
            if ($Remaining[$i] -eq "--body" -and ($i+1) -lt $Remaining.Count) {
                $body = $Remaining[$i+1]; $i++
            } elseif ($Remaining[$i] -eq "--body-file" -and ($i+1) -lt $Remaining.Count) {
                $bf = $Remaining[$i+1]
                if (-not (Test-Path $bf)) { Write-Error "Body file not found: $bf"; exit 1 }
                $body = Get-Content $bf -Raw -ErrorAction Stop; $i++
            }
        }
        $payload = @{ title = $title; head = $head; base = $base }
        if ($body) { $payload.body = $body }
        $json = $payload | ConvertTo-Json -Compress -Depth 10
        Invoke-GitHubApi "repos/$Repo/pulls" -Method POST -Data $json
    }
    "comments" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> comments <number>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/issues/$num/comments" -Paginate
    }
    "merge" {
        $num = $Remaining[0]
        $method = $Remaining[1]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> merge <number> [merge|squash|rebase]"; exit 1 }
        $payload = @{}
        if ($method) { $payload.merge_method = $method }
        $json = $payload | ConvertTo-Json -Compress -Depth 10
        Invoke-GitHubApi "repos/$Repo/pulls/$num/merge" -Method PUT -Data $json
    }
    "comment" {
        $num = $Remaining[0]
        $body = $Remaining[1]
        if (-not $num -or -not $body) { Write-Error "Usage: gh-pr.ps1 <owner/repo> comment <number> <body>"; exit 1 }
        $json = @{ body = $body } | ConvertTo-Json -Compress -Depth 10
        Invoke-GitHubApi "repos/$Repo/issues/$num/comments" -Method POST -Data $json
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Commands: list, view <n>, create <title> <head> <base>, comments <n>, merge <n> [method], comment <n> <body>"
        exit 1
    }
}

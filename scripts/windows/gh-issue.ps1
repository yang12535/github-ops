#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Repo,
    [Parameter(Position=1)]
    [string]$Command = "list"
)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Api = "$ScriptDir\gh-api.ps1"

$Remaining = $args

switch ($Command) {
    "list" { & $Api "repos/$Repo/issues" -Paginate }
    "view" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> view <number>"; exit 1 }
        & $Api "repos/$Repo/issues/$num"
    }
    "create" {
        $title = $Remaining[0]
        $body = ""
        for ($i = 1; $i -lt $Remaining.Count; $i++) {
            if ($Remaining[$i] -eq "--body" -and ($i+1) -lt $Remaining.Count) {
                $body = $Remaining[$i+1]; $i++
            } elseif ($Remaining[$i] -eq "--body-file" -and ($i+1) -lt $Remaining.Count) {
                $body = Get-Content $Remaining[$i+1] -Raw; $i++
            }
        }
        $payload = @{ title = $title }
        if ($body) { $payload.body = $body }
        & $Api "repos/$Repo/issues" "POST" ($payload | ConvertTo-Json -Depth 10)
    }
    "close" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> close <number>"; exit 1 }
        & $Api "repos/$Repo/issues/$num" "PATCH" '{"state":"closed"}'
    }
    "reopen" {
        $num = $Remaining[0]
        if (-not $num) { Write-Error "Usage: gh-issue.ps1 <owner/repo> reopen <number>"; exit 1 }
        & $Api "repos/$Repo/issues/$num" "PATCH" '{"state":"open"}'
    }
    "comment" {
        $num = $Remaining[0]
        $body = $Remaining[1]
        if (-not $num -or -not $body) { Write-Error "Usage: gh-issue.ps1 <owner/repo> comment <number> <body>"; exit 1 }
        $payload = @{ body = $body } | ConvertTo-Json -Depth 10 -Compress
        & $Api "repos/$Repo/issues/$num/comments" -Method "POST" -Data $payload
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Commands: list, view <n>, create <title>, close <n>, reopen <n>, comment <n> <body>"
        exit 1
    }
}

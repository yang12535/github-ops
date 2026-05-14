#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Quick PR operations for Windows (PowerShell).
.DESCRIPTION
    Uses gh-api.ps1 internally. No Python required.
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Repo,

    [Parameter(Position=1)]
    [string]$Command = "list",

    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Api = "$ScriptDir\gh-api.ps1"

function Invoke-Api { param($Endpoint, $Method="GET", $Body=$null)
    $params = @{ Endpoint = $Endpoint; Method = $Method }
    if ($Body) { $params.Data = ($Body | ConvertTo-Json -Depth 10) }
    & $Api @params
}

switch ($Command) {
    "list" {
        & $Api "repos/$Repo/pulls" -Paginate
    }
    "view" {
        $num = $Args[0]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> view <number>"; exit 1 }
        & $Api "repos/$Repo/pulls/$num"
    }
    "create" {
        if ($Args.Count -lt 3) { Write-Error "Usage: gh-pr.ps1 <owner/repo> create <title> <head> <base> [--body <text>|--body-file <path>]"; exit 1 }
        $title = $Args[0]
        $head = $Args[1]
        $base = $Args[2]
        $body = ""
        for ($i = 3; $i -lt $Args.Count; $i++) {
            if ($Args[$i] -eq "--body" -and ($i+1) -lt $Args.Count) {
                $body = $Args[$i+1]; $i++
            } elseif ($Args[$i] -eq "--body-file" -and ($i+1) -lt $Args.Count) {
                $body = Get-Content $Args[$i+1] -Raw; $i++
            }
        }
        $payload = @{ title = $title; head = $head; base = $base }
        if ($body) { $payload.body = $body }
        Invoke-Api "repos/$Repo/pulls" "POST" $payload
    }
    "comments" {
        $num = $Args[0]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> comments <number>"; exit 1 }
        & $Api "repos/$Repo/issues/$num/comments" -Paginate
    }
    "merge" {
        $num = $Args[0]
        $method = $Args[1]
        if (-not $num) { Write-Error "Usage: gh-pr.ps1 <owner/repo> merge <number> [merge|squash|rebase]"; exit 1 }
        $payload = @{}
        if ($method) { $payload.merge_method = $method }
        Invoke-Api "repos/$Repo/pulls/$num/merge" "PUT" $payload
    }
    "comment" {
        $num = $Args[0]
        $body = $Args[1]
        if (-not $num -or -not $body) { Write-Error "Usage: gh-pr.ps1 <owner/repo> comment <number> <body>"; exit 1 }
        Invoke-Api "repos/$Repo/issues/$num/comments" "POST" @{ body = $body }
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Commands: list, view <n>, create <title> <head> <base>, comments <n>, merge <n> [method], comment <n> <body>"
        exit 1
    }
}

#!/usr/bin/env pwsh
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Repo,
    [Parameter(Position=1)]
    [string]$Action = "view"
)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Api = "$ScriptDir\gh-api.ps1"

switch ($Action) {
    "view" { & $Api "repos/$Repo" }
    "issues" { & $Api "repos/$Repo/issues" -Paginate }
    "prs" { & $Api "repos/$Repo/pulls" -Paginate }
    "commits" { & $Api "repos/$Repo/commits" -Paginate }
    "releases" { & $Api "repos/$Repo/releases" -Paginate }
    "contents" {
        $path = $Args[0]
        if (-not $path) { Write-Error "Usage: gh-repo.ps1 <owner/repo> contents <path>"; exit 1 }
        & $Api "repos/$Repo/contents/$path"
    }
    "url" { (& $Api "repos/$Repo" | ConvertFrom-Json).html_url }
    default {
        Write-Error "Unknown action: $Action"
        Write-Host "Actions: view, issues, prs, commits, releases, contents <path>, url"
        exit 1
    }
}

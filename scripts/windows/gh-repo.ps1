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
    "url" { (& $Api "repos/$Repo" | ConvertFrom-Json).html_url }
    default {
        Write-Error "Unknown action: $Action"
        Write-Host "Actions: view, issues, prs, commits, releases, url"
        exit 1
    }
}

#!/usr/bin/env pwsh
# Windows entrypoint for gh-repo — delegates to ../gh-api.py (Python).

param(
    [Parameter(Mandatory, Position = 0)][string]$Repo,
    [Parameter(Position = 1)]
    [ValidateSet("view", "issues", "prs", "commits", "releases", "contents", "url")]
    [string]$Action = "view"
)

. $PSScriptRoot\_common.ps1

switch ($Action) {
    "view" { Invoke-GitHubApi "repos/$Repo" }
    "issues" { Invoke-GitHubApi "repos/$Repo/issues" -Paginate }
    "prs" { Invoke-GitHubApi "repos/$Repo/pulls" -Paginate }
    "commits" { Invoke-GitHubApi "repos/$Repo/commits" -Paginate }
    "releases" { Invoke-GitHubApi "repos/$Repo/releases" -Paginate }
    "contents" {
        $path = $Args[0]
        if (-not $path) { Write-Error "Usage: gh-repo.ps1 <owner/repo> contents <path>"; exit 1 }
        Invoke-GitHubApi "repos/$Repo/contents/$path"
    }
    "url" { Invoke-GitHubApi "repos/$Repo" -Field "html_url" }
    default {
        Write-Error "Unknown action: $Action"
        Write-Host "Actions: view, issues, prs, commits, releases, contents <path>, url"
        exit 1
    }
}

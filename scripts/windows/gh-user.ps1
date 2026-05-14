#!/usr/bin/env pwsh
# Windows entrypoint for gh-user — delegates to ../gh-api.py (Python).

param([string]$Username)

. $PSScriptRoot\_common.ps1

$endpoint = if ($Username) { "users/$Username" } else { "user" }
Invoke-GitHubApi $endpoint

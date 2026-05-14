#!/usr/bin/env pwsh
# Windows entrypoint for gh-user — delegates to ../gh-api.py (Python).

. $PSScriptRoot\_common.ps1

param([string]$Username)

$endpoint = if ($Username) { "users/$Username" } else { "user" }
Invoke-GitHubApi $endpoint

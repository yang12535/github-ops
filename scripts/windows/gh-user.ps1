#!/usr/bin/env pwsh
param([string]$Username)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$Api = "$ScriptDir\gh-api.ps1"
$endpoint = if ($Username) { "users/$Username" } else { "user" }
& $Api $endpoint

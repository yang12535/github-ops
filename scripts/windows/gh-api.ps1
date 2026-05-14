#!/usr/bin/env pwsh
<#
.SYNOPSIS
    GitHub API wrapper for Windows (PowerShell/Invoke-RestMethod).
.DESCRIPTION
    Pure PowerShell implementation using Invoke-RestMethod.
    No Python required. Auth via gh CLI, env vars, or fallback token files.
#>

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Endpoint,

    [string]$Method = "GET",
    [string]$Data,
    [switch]$Paginate,
    [switch]$Compact,
    [switch]$Quiet,
    [string[]]$Field
)

function Get-GitHubToken {
    # 1. gh CLI
    try {
        $token = (& gh auth token 2>$null).Trim()
        if ($token) { return $token }
    } catch {}

    # 2. Environment
    $token = $env:GITHUB_TOKEN, $env:GH_TOKEN | Where-Object { $_ } | Select-Object -First 1
    if ($token) { return $token }

    # 3. Fallback files (user-private paths only)
    $fallbackPaths = @(
        "$env:USERPROFILE\.github_token",
        "$env:USERPROFILE\.config\github-ops\token",
        "$env:USERPROFILE\github_token.txt"
    )
    foreach ($path in $fallbackPaths) {
        if (Test-Path $path) {
            $token = (Get-Content $path -Raw -ErrorAction SilentlyContinue).Trim()
            if ($token) { return $token }
        }
    }

    Write-Error "No GitHub token found. Run 'gh auth login' or set GITHUB_TOKEN env." -ErrorAction Stop
}

function Invoke-GitHubApi {
    param($Endpoint, $Method="GET", $BodyObj=$null)

    $token = Get-GitHubToken
    $uri = "https://api.github.com/$($Endpoint.TrimStart('/'))"

    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "github-ops-windows"
    }

    $params = @{
        Uri = $uri
        Method = $Method
        Headers = $headers
    }
    if ($BodyObj) {
        $params.Body = ($BodyObj | ConvertTo-Json -Depth 10)
        $params.ContentType = "application/json"
    }

    try {
        $resp = Invoke-RestMethod @params
        return ,$resp
    } catch {
        $status = $_.Exception.Response?.StatusCode.value__
        $msgText = $_.ErrorDetails.Message
        $msg = $null
        if ($msgText) {
            try { $msg = $msgText | ConvertFrom-Json -ErrorAction Stop } catch {}
        }
        $errMsg = if ($msg.message) { $msg.message } else { $_.Exception.Message }
        return @{ error = $true; status = $status; message = $errMsg }
    }
}

function Invoke-GitHubApiPaginate {
    param($Endpoint, $Method="GET", $BodyObj=$null, $MaxPages=10)

    $token = Get-GitHubToken
    $uri = "https://api.github.com/$($Endpoint.TrimStart('/'))"
    $results = @()
    $pages = 0

    $headers = @{
        "Authorization" = "token $token"
        "Accept" = "application/vnd.github.v3+json"
        "User-Agent" = "github-ops-windows"
    }

    while ($uri -and $pages -lt $MaxPages) {
        $pages++
        $params = @{ Uri = $uri; Method = $Method; Headers = $headers }
        if ($BodyObj) {
            $params.Body = ($BodyObj | ConvertTo-Json -Depth 10)
            $params.ContentType = "application/json"
        }

        try {
            $resp = Invoke-WebRequest @params
            $content = $resp.Content
            if ($content.TrimStart() -match '^\[') {
                $pageData = @($content | ConvertFrom-Json)
            } else {
                $pageData = $content | ConvertFrom-Json
            }
            if ($pageData -is [array]) {
                $results += $pageData
            } else {
                return $pageData
            }

            # Parse Link header
            $linkHeader = $resp.Headers["Link"]
            $uri = $null
            if ($linkHeader) {
                foreach ($part in $linkHeader -split ',') {
                    if ($part -match '<([^>]+)>;\s*rel="next"') {
                        $uri = $matches[1]
                        break
                    }
                }
            }
        } catch {
            return @{ error = $true; message = $_.Exception.Message }
        }
    }
    return $results
}

# Main
$bodyObj = $null
if ($Data) {
    if ($Data.StartsWith('@')) {
        $bodyObj = Get-Content $Data.Substring(1) -Raw | ConvertFrom-Json
    } else {
        $bodyObj = $Data | ConvertFrom-Json
    }
}

try {
    if ($Paginate) {
        $result = Invoke-GitHubApiPaginate $Endpoint $Method $bodyObj
    } else {
        $result = Invoke-GitHubApi $Endpoint $Method $bodyObj
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

if ($result -and $result.error) {
    $result | ConvertTo-Json -Depth 5 -Compress:$Compact | Out-Host
    exit 1
}

if ($Quiet) { exit 0 }

if ($Field -and $result -ne $null) {
    foreach ($f in $Field) {
        $keys = $f -split '\.'
        $val = $result
        foreach ($k in $keys) {
            if ($val -is [System.Collections.IDictionary] -and $val.ContainsKey($k)) {
                $val = $val[$k]
            } elseif ($val.PSObject.Properties[$k]) {
                $val = $val.$k
            } elseif ($val -is [array] -and $k -match '^\d+$') {
                $idx = [int]$k
                if ($idx -lt $val.Count) { $val = $val[$idx] } else { $val = $null; break }
            } else {
                $val = $null; break
            }
        }
        if ($val -ne $null) {
            if ($val -is [System.Collections.IDictionary] -or $val -is [array]) {
                $val | ConvertTo-Json -Depth 5 -Compress:$Compact
            } else {
                $val
            }
        }
    }
    exit 0
}

$result | ConvertTo-Json -Depth 5 -Compress:$Compact

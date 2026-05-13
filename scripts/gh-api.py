#!/usr/bin/env python3
"""GitHub API wrapper using urllib with gh auth token fallback to GITHUB_TOKEN."""

import argparse
import json
import os
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request


def get_token():
    """Get token from gh CLI or environment."""
    try:
        result = subprocess.run(
            ["gh", "auth", "token"],
            capture_output=True, text=True, check=True, timeout=10
        )
        token = result.stdout.strip()
        if token:
            return token
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        pass
    
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if token:
        return token
    
    print("Error: No GitHub token found. Run 'gh auth login' or set GITHUB_TOKEN env.", file=sys.stderr)
    sys.exit(1)


def api_call(endpoint, method="GET", data=None, headers=None):
    token = get_token()
    url = f"https://api.github.com/{endpoint.lstrip('/')}"
    
    req_headers = {
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github.v3+json",
        "User-Agent": "github-ops-skill"
    }
    if headers:
        req_headers.update(headers)
    
    payload = None
    if data is not None:
        if isinstance(data, dict):
            payload = json.dumps(data).encode("utf-8")
        elif isinstance(data, str):
            payload = data.encode("utf-8")
        elif isinstance(data, bytes):
            payload = data
        req_headers["Content-Type"] = "application/json"
    
    req = urllib.request.Request(url, data=payload, headers=req_headers, method=method)
    
    try:
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            if body:
                return json.loads(body)
            return {}
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        try:
            err = json.loads(body)
        except json.JSONDecodeError:
            err = {"message": body or str(e)}
        return {"error": True, "status": e.code, "message": err.get("message", str(e))}
    except urllib.error.URLError as e:
        return {"error": True, "status": 0, "message": str(e.reason)}


def paginate(endpoint, method="GET", data=None, params=None, max_pages=10):
    """Paginate through API list results using Link header."""
    token = get_token()
    results = []
    
    url = f"https://api.github.com/{endpoint.lstrip('/')}"
    if params:
        query = "&".join(f"{k}={urllib.parse.quote(str(v))}" for k, v in params.items())
        url = f"{url}?{query}"
    
    pages = 0
    payload = json.dumps(data).encode("utf-8") if data else None
    
    while url and pages < max_pages:
        pages += 1
        req = urllib.request.Request(
            url,
            data=payload,
            headers={
                "Authorization": f"token {token}",
                "Accept": "application/vnd.github.v3+json",
                "User-Agent": "github-ops-skill"
            },
            method=method
        )
        with urllib.request.urlopen(req) as resp:
            body = resp.read().decode("utf-8")
            page_data = json.loads(body)
            if isinstance(page_data, list):
                results.extend(page_data)
            else:
                return page_data
            
            link_header = resp.headers.get("Link", "")
            url = None
            for link in link_header.split(","):
                if 'rel="next"' in link:
                    start = link.find("<") + 1
                    end = link.find(">")
                    if start > 0 and end > start:
                        url = link[start:end]
                    break
    return results


def extract_field(obj, field_path):
    """Extract nested field using dot notation."""
    keys = field_path.split(".")
    val = obj
    for k in keys:
        if isinstance(val, dict) and k in val:
            val = val[k]
        elif isinstance(val, list) and k.isdigit():
            idx = int(k)
            if idx < len(val):
                val = val[idx]
            else:
                return None
        else:
            return None
    return val


def main():
    parser = argparse.ArgumentParser(description="GitHub API wrapper (curl-auth-api based)")
    parser.add_argument("endpoint", help="API endpoint, e.g. user, repos/owner/repo/issues")
    parser.add_argument("-X", "--method", default="GET", help="HTTP method")
    parser.add_argument("-d", "--data", help="JSON data string or @file")
    parser.add_argument("-p", "--paginate", action="store_true", help="Auto-paginate list results")
    parser.add_argument("-c", "--compact", action="store_true", help="Compact JSON output")
    parser.add_argument("-q", "--quiet", action="store_true", help="Suppress output, only return code")
    parser.add_argument("-f", "--field", action="append", help="Filter output field (dot notation)")
    
    args = parser.parse_args()
    
    data = None
    if args.data:
        if args.data.startswith("@"):
            with open(args.data[1:], "r", encoding="utf-8") as f:
                data = json.load(f)
        else:
            data = json.loads(args.data)
    
    try:
        if args.paginate:
            result = paginate(args.endpoint, args.method, data)
        else:
            result = api_call(args.endpoint, args.method, data)
    except Exception as e:
        print(json.dumps({"error": True, "message": str(e)}), file=sys.stderr)
        sys.exit(1)
    
    if result and isinstance(result, dict) and result.get("error"):
        print(json.dumps(result, indent=None if args.compact else 2, ensure_ascii=False))
        sys.exit(1)
    
    if args.quiet:
        sys.exit(0)
    
    if args.field and result is not None:
        for field in args.field:
            val = extract_field(result, field)
            if val is not None:
                if isinstance(val, (dict, list)):
                    print(json.dumps(val, indent=None if args.compact else 2, ensure_ascii=False))
                else:
                    print(val)
        return
    
    print(json.dumps(result, indent=None if args.compact else 2, ensure_ascii=False))


if __name__ == "__main__":
    main()

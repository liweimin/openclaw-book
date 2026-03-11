param(
  [string[]]$Hosts = @(
    "www.stats.gov.cn",
    "36kr.com",
    "api.moonshot.cn",
    "api.search.brave.com"
  )
)

function Invoke-Wsl {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Command
  )

  wsl.exe -e sh -lc $Command
}

function Invoke-WslPython {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Code
  )

  wsl.exe -e python3 -c $Code
}

Write-Host "=== OpenClaw config summary ==="
$configCode = "import json,pathlib; p=pathlib.Path.home()/'.openclaw'/'openclaw.json'; obj=json.loads(p.read_text()); search=obj.get('tools',{}).get('web',{}).get('search',{}); browser=obj.get('browser',{}); print('search.provider =', search.get('provider')); print('kimi.baseUrl =', search.get('kimi',{}).get('baseUrl')); print('browser.enabled =', browser.get('enabled')); print('browser.defaultProfile =', browser.get('defaultProfile')); print('browser.executablePath =', browser.get('executablePath'))"
Invoke-WslPython $configCode

Write-Host ""
Write-Host "=== Gateway status ==="
Invoke-Wsl "~/.npm-global/bin/openclaw gateway status"

Write-Host ""
Write-Host "=== Channel probe ==="
Invoke-Wsl "~/.npm-global/bin/openclaw channels status --probe"

$quotedHosts = ($Hosts | ForEach-Object { "'" + $_.Replace("'", "\\'") + "'" }) -join ", "
$resolveCode = "import ipaddress,socket; hosts=[$quotedHosts]; fake_ip_net=ipaddress.ip_network('198.18.0.0/15');`nfor host in hosts:`n    ips=[]`n    try:`n        infos=socket.getaddrinfo(host,443,type=socket.SOCK_STREAM)`n        for info in infos:`n            ip=info[4][0]`n            if ip not in ips:`n                ips.append(ip)`n        flags=[]`n        for ip in ips:`n            addr=ipaddress.ip_address(ip)`n            if addr in fake_ip_net:`n                flags.append(f'{ip}:RFC2544_FAKE_IP')`n            elif addr.is_private or addr.is_loopback or addr.is_link_local or addr.is_reserved:`n                flags.append(f'{ip}:SPECIAL_USE')`n            else:`n                flags.append(f'{ip}:PUBLIC')`n        print(host, '=>', ', '.join(flags))`n    except Exception as exc:`n        print(host, '=> ERR', exc)"

Write-Host ""
Write-Host "=== WSL DNS resolution ==="
$resolutionOutput = Invoke-WslPython $resolveCode
$resolutionOutput

Write-Host ""
Write-Host "=== Browser smoke ==="
Invoke-Wsl "~/.npm-global/bin/openclaw browser tabs || true"

Write-Host ""
Write-Host "=== Recent relevant log lines ==="
$logDate = Get-Date -Format "yyyy-MM-dd"
Invoke-Wsl "grep -nEi 'private/internal/special-use|Failed to start Chrome CDP|browser.request|moonshot|kimi' /tmp/openclaw/openclaw-$logDate.log | tail -n 20 || true"

Write-Host ""
Write-Host "=== Heuristics ==="
if ($resolutionOutput -match "RFC2544_FAKE_IP") {
  Write-Host "- Detected Clash-style fake-ip (198.18.0.0/15). Built-in web_fetch will likely be blocked by SSRF checks."
  Write-Host "- In this state, adding FIRECRAWL_API_KEY to built-in web_fetch is not enough, because SSRF block happens before Firecrawl fallback."
  Write-Host "- Fix DNS/fake-ip first, or switch fetch/crawl to an external Firecrawl skill."
}
if ($resolutionOutput -notmatch "RFC2544_FAKE_IP") {
  Write-Host "- No RFC2544 fake-ip detected in the sampled hosts."
}
Write-Host "- If browser still times out, verify WSL can reach a Windows Chrome CDP endpoint before comparing web_fetch vs browser."

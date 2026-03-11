param(
  [Parameter(Mandatory=$true)]
  [ValidateSet("brave","kimi","gemini")]
  [string]$Provider,

  [string]$KimiBaseUrl
)

$linuxConfig = '/home/levimin/.openclaw/openclaw.json'
$providerLiteral = $Provider.Replace("'", "\\'")
$kimiBaseUrlLiteral = ""
if ($KimiBaseUrl) {
  $kimiBaseUrlLiteral = $KimiBaseUrl.Replace("'", "\\'")
}

$python = @"
import json
from pathlib import Path
p = Path('$linuxConfig')
data = json.loads(p.read_text())
search = data.setdefault('tools', {}).setdefault('web', {}).setdefault('search', {})
search['provider'] = '$providerLiteral'
target_kimi_base_url = '$kimiBaseUrlLiteral'.strip()
if search['provider'] == 'kimi' and target_kimi_base_url:
    search.setdefault('kimi', {})['baseUrl'] = target_kimi_base_url
p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + '\n')
print('provider=', search['provider'])
print('kimi_baseUrl=', search.get('kimi', {}).get('baseUrl'))
"@

wsl -e bash -lc "python3 - <<'PY'
$python
PY"
wsl -e bash -lc "~/.npm-global/bin/openclaw gateway restart 2>/dev/null || openclaw gateway restart"
if ($KimiBaseUrl) {
  Write-Host "Switched web_search provider to $Provider, set Kimi baseUrl to $KimiBaseUrl, and restarted gateway."
} else {
  Write-Host "Switched web_search provider to $Provider and restarted gateway."
}

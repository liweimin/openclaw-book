@echo off
setlocal

set "EDGE_EXE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
set "EDGE_CDP_PORT=9223"
set "RELAY_PORT=9224"
set "EDGE_USER_DATA_DIR=%LOCALAPPDATA%\Temp\openclaw-edge-remote"
set "RELAY_SCRIPT=%~dp0openclaw-cdp-relay.cjs"

echo Starting Edge remote CDP on 127.0.0.1:%EDGE_CDP_PORT%...
start "" "%EDGE_EXE%" --remote-debugging-port=%EDGE_CDP_PORT% --user-data-dir="%EDGE_USER_DATA_DIR%" --no-first-run --no-default-browser-check about:blank

echo Starting OpenClaw CDP relay on 0.0.0.0:%RELAY_PORT%...
start "OpenClaw CDP Relay" /min node "%RELAY_SCRIPT%"

echo.
echo Edge CDP:  http://127.0.0.1:%EDGE_CDP_PORT%/json/version
echo WSL relay: http://0.0.0.0:%RELAY_PORT%/json/version
echo.
echo In WSL, test with:
echo   curl http://172.18.240.1:%RELAY_PORT%/json/version

exit /b 0

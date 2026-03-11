@echo off
setlocal

set "EDGE_EXE=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
set "EDGE_USER_DATA_DIR=%LOCALAPPDATA%\Temp\openclaw-edge-relay"
set "EXT_DIR=%LOCALAPPDATA%\OpenClawBrowserRelay\Extension"

echo Starting Edge with OpenClaw relay extension...
start "" "%EDGE_EXE%" --user-data-dir="%EDGE_USER_DATA_DIR%" --disable-extensions-except="%EXT_DIR%" --load-extension="%EXT_DIR%" https://example.com

echo.
echo Extension relay should auto-attach the active tab.
echo Verify from WSL with:
echo   ~/.npm-global/bin/openclaw browser --browser-profile chrome tabs

exit /b 0

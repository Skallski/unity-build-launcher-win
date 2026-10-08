@echo off
setlocal
cd /d "%~dp0"

if not exist "%~dp0UnityAppsLauncher.ps1" (
    echo ERROR: UnityAppsLauncher.ps1 was not found.
    echo Keep both files in the same folder.
    pause
    exit /b 1
)

"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoLogo -NoProfile -ExecutionPolicy Bypass -STA -File "%~dp0UnityAppsLauncher.ps1"

if errorlevel 1 (
    echo.
    echo The launcher encountered an error. See the message above.
    pause
)

endlocal
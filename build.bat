@echo off
cd /d "%~dp0"

echo [1/2] Building frontend...
call npm run build
if errorlevel 1 (
    echo.
    echo ERROR: Frontend build failed.
    pause
    exit /b 1
)

echo.
echo [2/2] Building Tauri desktop app...
call npm run tauri build
if errorlevel 1 (
    echo.
    echo ERROR: Tauri build failed.
    pause
    exit /b 1
)

echo.
echo Build complete! Installer is in src-tauri\target\release\bundle\
pause

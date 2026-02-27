@echo off
cd /d "%~dp0"

if "%1"=="" (
    echo Usage: release.bat v1.0.0
    pause
    exit /b 1
)

set TAG=%1

echo Tagging %TAG% and pushing to GitHub...
git tag %TAG%
if errorlevel 1 (
    echo ERROR: Failed to create tag. Does it already exist?
    pause
    exit /b 1
)

git push origin %TAG%
if errorlevel 1 (
    echo ERROR: Failed to push tag.
    pause
    exit /b 1
)

echo.
echo Done! GitHub Actions will now build and publish the release.
echo Check progress at: https://github.com/iSTAYERi/flow-rate-calculator/actions
pause

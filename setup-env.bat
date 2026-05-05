@REM Setup script for Windows environments
@REM This script configures the necessary environment variables for React Native Android development

@echo off
echo ========================================
echo Android Environment Setup for Windows
echo ========================================
echo.

REM Check if Android SDK is installed
if exist "%LOCALAPPDATA%\Android\Sdk" (
    echo ✓ Android SDK found at: %LOCALAPPDATA%\Android\Sdk
    setx ANDROID_HOME "%LOCALAPPDATA%\Android\Sdk"
) else (
    echo ⚠ Android SDK not found. Please install Android Studio first.
    echo   Download from: https://developer.android.com/studio
    pause
    exit /b 1
)

REM Set additional environment variables
setx GRADLE_OPTS "-Xmx4096m"
echo ✓ GRADLE_OPTS set to: -Xmx4096m

REM Check Node.js
node --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✓ Node.js is installed: %node version%
) else (
    echo ⚠ Node.js is not installed or not in PATH
)

REM Check npm
npm --version >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✓ npm is installed
) else (
    echo ⚠ npm is not installed or not in PATH
)

echo.
echo ========================================
echo Environment setup complete!
echo ========================================
echo.
echo Please restart your terminal for changes to take effect.
echo.
pause

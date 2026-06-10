@echo off
title Claude Code Offline Installation - Windows
chcp 65001 >nul

echo ============================================
echo  Claude Code - Offline Installation (Windows)
echo  Version: 2.1.170
echo ============================================
echo.

REM Step 1: Check if Git is installed
where git >nul 2>&1
if %errorlevel% equ 0 (
    echo [✅] Git found: 
    git --version
) else (
    echo [⚠] Git for Windows is required.
    echo     Please install Git from: https://git-scm.com/
    echo     Or run: winget install Git.Git
    echo.
    echo     After installing Git, run this script again.
    pause
    exit /b 1
)

echo.
echo [1/4] Installing Claude Code binary...
echo.
if not exist "%~dp0claude.exe" (
    echo [ERROR] claude.exe not found in the same folder!
    echo         Make sure claude.exe is in the same directory as this script.
    pause
    exit /b 1
)

REM Create the target directory
if not exist "%USERPROFILE%\.local\bin" mkdir "%USERPROFILE%\.local\bin"

REM Copy the binary
copy /Y "%~dp0claude.exe" "%USERPROFILE%\.local\bin\claude.exe" >nul
echo [✅] Binary copied to %USERPROFILE%\.local\bin\claude.exe

REM Add to PATH if not already there
echo %PATH% | findstr /C:"%USERPROFILE%\.local\bin" >nul
if %errorlevel% neq 0 (
    echo [ℹ] Adding %USERPROFILE%\.local\bin to PATH...
    setx PATH "%USERPROFILE%\.local\bin;%PATH%" >nul
    echo [✅] Added to PATH (will apply in new terminal)
)

echo.
echo [2/4] Setting up Claude Code launcher...
cd /d "%USERPROFILE%\.local\bin"
claude.exe install >nul 2>&1
if %errorlevel% equ 0 (
    echo [✅] Claude Code launcher installed successfully
) else (
    echo [⚠] Note: Claude Code installed but launcher setup may need manual steps
)

echo.
echo [3/4] Copying configuration files...
if not exist "%USERPROFILE%\.claude" mkdir "%USERPROFILE%\.claude"
if exist "%~dp0..\config\settings.json" (
    copy /Y "%~dp0..\config\settings.json" "%USERPROFILE%\.claude\settings.json" >nul
    echo [✅] Configuration file installed
) else (
    echo [⚠] settings.json not found, will use defaults
)

echo.
echo [4/4] Verifying installation...
echo.
if exist "%USERPROFILE%\.local\bin\claude.exe" (
    for /f "tokens=*" %%a in ('"%USERPROFILE%\.local\bin\claude.exe" --version 2^>nul') do set CLAUDE_VER=%%a
    echo [✅] Claude Code installed successfully!
    echo    Version: %CLAUDE_VER%
) else (
    echo [ERROR] Installation failed - claude.exe not found
    pause
    exit /b 1
)

echo.
echo ============================================
echo  Installation Complete!
echo ============================================
echo.
echo  NEXT STEPS:
echo  1. Open a NEW PowerShell terminal
echo  2. Run the environment setup:
echo     .\scripts\setup-env-windows.ps1
echo.
echo  3. Or manually:
echo     set ANTHROPIC_BASE_URL=http://TBD:30000
echo     set ANTHROPIC_API_KEY=sk-offline
echo     set CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
echo     set CLAUDE_CODE_SIMPLE=1
echo.
echo  4. Launch Claude Code:
echo     claude --model DeepSeek-V4-Flash --bare
echo.
echo  NOTE: Update the IP address in settings.json
echo        to match your SGLang server address.
echo.
pause

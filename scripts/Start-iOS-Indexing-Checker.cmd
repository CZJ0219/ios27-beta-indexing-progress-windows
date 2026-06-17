@echo off
setlocal
title iOS Indexing Checker for Windows
chcp 65001 >nul
cd /d "%~dp0"

echo [%date% %time%] CMD launcher started>>"%~dp0ios-indexing-checker.log"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Start-iOS-Indexing-Checker.ps1"
echo [%date% %time%] PowerShell exited with %errorlevel%>>"%~dp0ios-indexing-checker.log"

# Ensure script runs as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[!] Restarting script with Administrator privileges..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Embedded Batch Engine
$batchContent = @"
@echo off
title Multi-Tool System Diagnostics ^& Optimizer
mode con cols=75 lines=28
color 0A

:MENU
cls
echo ===========================================================================
echo                       SYSTEM DIAGNOSTICS ^& REPAIR TOOL
echo ===========================================================================
echo.
echo   [1] Fast System Cleanup (Clear Temp Files ^& Prefetch)
echo   [2] Repair System Files (SFC /Scannow)
echo   [3] Network Reset (Flush DNS ^& Reset IP Stack)
echo   [4] Quick Hardware Info (CPU, RAM, OS Summary)
echo   [5] Check Disk Health Status (SMART)
echo   [Q] Exit
echo.
echo ===========================================================================
set /p choice=Select an option [1-5, Q]: 

if "%choice%"=="1" goto CLEANUP
if "%choice%"=="2" goto REPAIR
if "%choice%"=="3" goto FLUSHDNS
if "%choice%"=="4" goto SYSINFO
if "%choice%"=="5" goto DISKHEALTH
if /i "%choice%"=="Q" goto EXIT
goto MENU

:CLEANUP
cls
echo ===========================================================================
echo                         RUNNING SYSTEM CLEANUP
echo ===========================================================================
echo.
echo Cleaning Temp directories...
del /s /f /q "%temp%\*.*" >nul 2>&1
for /d %%p in ("%temp%\*.*") do rmdir /s /q "%%p" >nul 2>&1
del /s /f /q "C:\Windows\Temp\*.*" >nul 2>&1
for /d %%p in ("C:\Windows\Temp\*.*") do rmdir /s /q "%%p" >nul 2>&1
echo.
echo Cleaning Prefetch cache...
del /s /f /q "C:\Windows\Prefetch\*.*" >nul 2>&1
echo.
echo [DONE] Temporary files cleared successfully.
pause
goto MENU

:REPAIR
cls
echo ===========================================================================
echo                        SYSTEM FILE CHECKER (SFC)
echo ===========================================================================
echo.
echo Running SFC /Scannow... This may take a few minutes.
echo.
sfc /scannow
echo.
pause
goto MENU

:FLUSHDNS
cls
echo ===========================================================================
echo                        NETWORK RESET ^& FLUSH DNS
echo ===========================================================================
echo.
echo Flushing DNS Resolver Cache...
ipconfig /flushdns
echo.
echo Resetting Winsock Catalog...
netsh winsock reset >nul
echo.
echo [DONE] Network cache refreshed!
pause
goto MENU

:SYSINFO
cls
echo ===========================================================================
echo                           HARDWARE SUMMARY
echo ===========================================================================
echo.
systeminfo | findstr /B /C:"OS Name" /C:"OS Version" /C:"System Type" /C:"Total Physical Memory"
echo.
wmic cpu get Name, NumberOfCores, NumberOfLogicalProcessors | findstr /V "Name"
echo.
pause
goto MENU

:DISKHEALTH
cls
echo ===========================================================================
echo                          DISK HEALTH (SMART)
echo ===========================================================================
echo.
wmic diskdrive get Model, Status
echo.
pause
goto MENU

:EXIT
cls
echo Thank you for using System Diagnostics!
timeout /t 2 >nul
exit
"@

# Write Batch content to %TEMP% directory, execute, and automatically clean up
$tempBat = "$env:TEMP\sys_diag.bat"
$batchContent | Out-File -FilePath $tempBat -Encoding ascii

# Launch the interactive Batch application
Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBat`"" -Wait

# Remove temporary script file after exit
if (Test-Path $tempBat) { Remove-Item $tempBat -Force }

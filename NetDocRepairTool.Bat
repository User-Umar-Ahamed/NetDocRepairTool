@echo off
setlocal EnableExtensions EnableDelayedExpansion
title NetDoctor Pro - Network Repair & Diagnostics Tool (By Umar Ahamed)
color 0A

:: ========================================================
:: Admin Check
:: ========================================================
>nul 2>&1 net session || (
  echo ===========================================================
  echo  This tool must be run as Administrator!
  echo  Please right-click on this file and select "Run as administrator".
  echo ===========================================================
  pause
  exit /b
)

:: ========================================================
:: Setup Logging
:: ========================================================
set "LOG=%~dp0NetDoctorLog.txt"
echo === NetDoctor Pro started: %date% %time% === >>"%LOG%"
echo. >>"%LOG%"

:: ========================================================
:: Main Menu
:: ========================================================
:MENU
cls
echo ====================================================
echo     NetDoctor Pro - Network Repair and Diagnostics
echo                 Developed by Umar Ahamed
echo ====================================================
echo  1. Flush DNS Cache
echo  2. Reset Winsock and TCP/IP Stack
echo  3. Release and Renew IP Address
echo  4. Reset Proxy, Firewall, and Network Settings
echo  5. Restart All Network Services
echo  6. Diagnose Internet (Google + Gateway)
echo  7. View Current Network Status
echo  8. Scan Active Connections (netstat)
echo  9. Repair ALL (Options 1-5)
echo 10. Full Network Diagnostics (Auto Problem Check)
echo 11. View IP Details (Local + Public + Gateway + DNS)
echo 12. Restart System
echo  0. Exit
echo ====================================================
set /p CH=Enter your choice (0-12): 

IF "%CH%"=="1"  GOTO FLUSH_DNS
IF "%CH%"=="2"  GOTO RESET_STACK
IF "%CH%"=="3"  GOTO RENEW_IP
IF "%CH%"=="4"  GOTO RESET_PROXY_FW
IF "%CH%"=="5"  GOTO RESTART_SERV
IF "%CH%"=="6"  GOTO DIAG_INTERNET
IF "%CH%"=="7"  GOTO STATUS
IF "%CH%"=="8"  GOTO NETSTAT_SCAN
IF "%CH%"=="9"  GOTO REPAIR_ALL
IF "%CH%"=="10" GOTO FULL_DIAG
IF "%CH%"=="11" GOTO IP_DETAILS
IF "%CH%"=="12" GOTO RESTART_SYSTEM
IF "%CH%"=="0"  GOTO END
GOTO MENU

:: ========================================================
:: Utility Functions
:: ========================================================
:PauseReturn
echo.
echo Press Enter to return to menu...
pause >nul
GOTO MENU

:Log
echo [%date% %time%] %* >>"%LOG%"
echo %*
GOTO :EOF

:: ========================================================
:: Option 1 - Flush DNS
:: ========================================================
:FLUSH_DNS
call :Log "Flushing DNS cache..."
ipconfig /flushdns >>"%LOG%" 2>&1
call :Log "DNS cache flushed."
GOTO PauseReturn

:: ========================================================
:: Option 2 - Reset Winsock / TCP / IP
:: ========================================================
:RESET_STACK
call :Log "Resetting Winsock and TCP/IP settings..."
netsh winsock reset >>"%LOG%" 2>&1
netsh int ip reset >>"%LOG%" 2>&1
call :Log "Winsock/TCP/IP reset successfully."
GOTO PauseReturn

:: ========================================================
:: Option 3 - Release/Renew IP
:: ========================================================
:RENEW_IP
call :Log "Releasing and renewing IP address..."
ipconfig /release >>"%LOG%" 2>&1
ipconfig /renew >>"%LOG%" 2>&1
call :Log "IP address renewed successfully."
GOTO PauseReturn

:: ========================================================
:: Option 4 - Reset Proxy / Firewall
:: ========================================================
:RESET_PROXY_FW
call :Log "Resetting proxy, internet, and firewall settings..."
netsh winhttp reset proxy >>"%LOG%" 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /f >>"%LOG%" 2>&1
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /f >>"%LOG%" 2>&1
netsh advfirewall reset >>"%LOG%" 2>&1
call :Log "Proxy and firewall settings reset."
GOTO PauseReturn

:: ========================================================
:: Option 5 - Restart Network Services
:: ========================================================
:RESTART_SERV
call :Log "Restarting core network services..."
for %%S in (Dhcp Dnscache BITS NlaSvc WlanSvc Netlogon) do (
  net stop "%%S" >>"%LOG%" 2>&1
  net start "%%S" >>"%LOG%" 2>&1
)
call :Log "Network services restarted."
GOTO PauseReturn

:: ========================================================
:: Option 6 - Diagnose Internet Connectivity
:: ========================================================
:DIAG_INTERNET
call :Log "Diagnosing internet connectivity..."
echo Pinging gateway...
ping -n 2 192.168.1.1 >>"%LOG%" 2>&1
echo Pinging 8.8.8.8...
ping -n 2 8.8.8.8 >>"%LOG%" 2>&1
echo Pinging google.com...
ping -n 2 google.com >>"%LOG%" 2>&1
call :Log "Internet diagnostics complete."
GOTO PauseReturn

:: ========================================================
:: Option 7 - View Network Status
:: ========================================================
:STATUS
call :Log "Showing full network config..."
ipconfig /all | more
GOTO PauseReturn

:: ========================================================
:: Option 8 - Netstat Scan
:: ========================================================
:NETSTAT_SCAN
call :Log "Scanning active network connections..."
netstat -ano | more
GOTO PauseReturn

:: ========================================================
:: Option 9 - Repair ALL
:: ========================================================
:REPAIR_ALL
call :Log "Running full repair (all steps)..."
echo [1/5] Flushing DNS...
ipconfig /flushdns >>"%LOG%"
echo [2/5] Resetting Winsock/TCP/IP...
netsh winsock reset >>"%LOG%"
netsh int ip reset >>"%LOG%"
echo [3/5] Releasing/Renewing IP...
ipconfig /release >>"%LOG%"
ipconfig /renew >>"%LOG%"
echo [4/5] Resetting Proxy & Firewall...
netsh winhttp reset proxy >>"%LOG%"
netsh advfirewall reset >>"%LOG%"
echo [5/5] Restarting network services...
for %%S in (Dhcp Dnscache BITS NlaSvc WlanSvc Netlogon) do (
  net stop "%%S" >>"%LOG%" 2>&1
  net start "%%S" >>"%LOG%" 2>&1
)
call :Log "Full repair completed."
echo.
echo ✅ Repairs complete.
echo.
GOTO RESTART_PROMPT

:: ========================================================
:: Option 10 - Full Network Diagnostics
:: ========================================================
:FULL_DIAG
call :Log "Running full diagnostics..."
nslookup google.com >>"%LOG%"
ping -n 2 8.8.8.8 >>"%LOG%"
route print >>"%LOG%"
call :Log "Diagnostics complete. Check NetDoctorLog.txt"
GOTO PauseReturn

:: ========================================================
:: Option 11 - View IP Details
:: ========================================================
:IP_DETAILS
call :Log "Collecting IP details..."

echo Local IP:
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /i "IPv4 Address"') do echo %%a

echo.
echo Public IP:
for /f "tokens=2 delims=:" %%a in ('nslookup myip.opendns.com resolver1.opendns.com ^| findstr Address ^| findstr /v 127') do echo %%a

echo.
GOTO PauseReturn

:: ========================================================
:: Restart Prompt
:: ========================================================
:RESTART_PROMPT
echo Would you like to restart now? (Y/N)
set /p OP=
IF /I "%OP%"=="Y" GOTO RESTART_SYSTEM
GOTO MENU

:: ========================================================
:: Option 12 - Restart System
:: ========================================================
:RESTART_SYSTEM
call :Log "Restarting system..."
echo System will restart in 10 seconds...
echo Press CTRL+C to cancel.
shutdown /r /t 10
exit /b

:: ========================================================
:: Exit
:: ========================================================
:END
call :Log "Exiting NetDoctor Pro..."
echo Log file saved as: %LOG%
exit /b

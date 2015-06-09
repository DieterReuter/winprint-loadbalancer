@echo off

set SRC="C:\vagrant\install\opt"
set DEST="C:\opt\"
set NSSM="C:\opt\nssm.exe"
set MONITOR="C:\opt\monitor-spooler.exe"
set SERVICE_NAME=SEAL Monitor PrintSpooler
set SERVICE_DESCRIPTION=SEAL Monitor PrintSpooler
set SERVICE_LOGFILE="C:\opt\monitor-spooler.log"
set SERVICE_PARAMETERS=""
set SERVICE_USERNAME=".\vagrant"
set SERVICE_PASSWORD="vagrant"


:rem ---DO NOT EDIT BEYOND---

echo.
echo Script: install-monitor.bat startet...
echo.

if not exist "%DEST%" (
  echo.
  echo Copy files to %DEST%
  echo.
  xcopy /Y /E "%SRC%" "%DEST%"
) 

echo.
echo [SC] Stopping service "%SERVICE_NAME%"
sc stop "%SERVICE_NAME%" >NUL 2>NUL

echo [NSSM] Trying to remove possibly pre-existing service "%SERVICE_NAME%"...
"%NSSM%" remove "%SERVICE_NAME%" confirm > NUL 2>NUL
"%NSSM%" install "%SERVICE_NAME%" "%MONITOR%"
"%NSSM%" set "%SERVICE_NAME%" AppParameters "%SERVICE_PARAMETERS%"
"%NSSM%" set "%SERVICE_NAME%" AppStdout "%SERVICE_LOGFILE%"
"%NSSM%" set "%SERVICE_NAME%" AppStderr "%SERVICE_LOGFILE%"
"%NSSM%" set "%SERVICE_NAME%" Description "%SERVICE_DESCRIPTION%"
"%NSSM%" set "%SERVICE_NAME%" ObjectName "%SERVICE_USERNAME%" "%SERVICE_PASSWORD%"

if not errorlevel 1 (
  :rem echo.
  :rem echo [SC] Configuring Service to allow access to desktop
  :rem echo.
  :rem sc config "%SERVICE_NAME%" type= own type= interact
  echo.
  echo [SC] Starting MONITOR Service
  echo.
  sc start "%SERVICE_NAME%"
)

echo [NETSH] Open firewall ports 8000
netsh advfirewall firewall add rule name="SEAL Monitor PrintSpooler Port 8000" dir=in action=allow protocol=TCP localport=8000

echo.
echo MONITOR Service should be available at:
echo     http://127.0.0.1:8000/health
echo     http://%COMPUTERNAME%:8000/health
echo.
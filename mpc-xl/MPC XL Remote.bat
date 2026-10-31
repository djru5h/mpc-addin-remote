@echo off
title MPC XL Remote
rem The XL's SSH name or address, such as root@192.168.1.50
set MPC_HOST=mpcxl
set ANS=
rem Is MPC Remote loaded inside MPC? A reboot takes it out. ssh itself failing exits 255.
ssh -o ConnectTimeout=10 %MPC_HOST% "sh /data/mpc-remote/is-loaded.sh"
if errorlevel 255 goto noconnect
if not errorlevel 1 goto tunnel

echo.
echo MPC Remote isn't loaded in MPC, probably because the XL has rebooted.
echo Loading it brings back the hardware buttons, but it RESTARTS MPC: anything unsaved is lost.
echo.
set /p ANS=Type Y to restart MPC and load it, or just press Enter for screen and mouse only:
if /i "%ANS%"=="Y" goto load
ssh -o ConnectTimeout=10 %MPC_HOST% "sh /data/mpc-remote/start.sh"
if errorlevel 1 goto failed
goto tunnel

:load
echo Loading, this takes about a minute...
ssh -o ConnectTimeout=10 %MPC_HOST% "sh /data/mpc-remote/load-into-mpc.sh"
if errorlevel 1 goto failed

:tunnel
rem The tunnel below blocks, so open the browser from a hidden window once the tunnel has had a moment to connect
start "" /min powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep 3; Start-Process 'http://localhost:6721'"
echo Tunnel open on http://localhost:6721 - close this window to disconnect. MPC Remote keeps running on the XL until it reboots.
rem Port 6721 here, so this can stay open beside the MPC One's tunnel on 6720
ssh -N -L 6721:127.0.0.1:6720 %MPC_HOST%
pause
exit /b 0

:noconnect
echo.
echo Could not reach the XL. If it has rebooted, answer the SSH stick's prompt on the XL, then run this again.
pause
exit /b 1

:failed
echo.
echo MPC Remote didn't start. The messages above say why.
pause
exit /b 1

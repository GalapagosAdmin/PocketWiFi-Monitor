@echo off
SET THEFILE=PocketWifiMonitor.exe
echo Linking %THEFILE%
c:\lazarus\fpc\2.5.1\bin\i386-win32\ld.exe -b pei-i386 -m i386pe  --gc-sections  -s --subsystem windows --entry=_WinMainCRTStartup    -o PocketWifiMonitor.exe link.res
if errorlevel 1 goto linkend
c:\lazarus\fpc\2.5.1\bin\i386-win32\postw32.exe --subsystem gui --input PocketWifiMonitor.exe --stack 16777216
if errorlevel 1 goto linkend
goto end
:asmend
echo An error occured while assembling %THEFILE%
goto end
:linkend
echo An error occured while linking %THEFILE%
:end

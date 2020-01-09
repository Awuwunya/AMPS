@echo off
set MAINDIR=%CD%
set COMPDIR="C:\MinGW\mingw32\bin"
cd /d %COMPDIR%

g++.exe -static-libgcc -static-libstdc++ "%MAINDIR%\ConvPCM.c" -o "%MAINDIR%\ConvPCM.exe"

pause

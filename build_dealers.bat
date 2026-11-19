@echo off
cd /d "%~dp0gamemodes"
"..\pawno\pawncc.exe" new.pwn "-i..\pawno\include" "-;+" "-(+" "-d3"
pause

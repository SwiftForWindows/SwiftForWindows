@echo off

rem Update the Path if bin is not contained
echo ;%PATH%; | find /C /I "%~dp0bin;" 1> NUL
if "%errorlevel%"=="1"  set PATH=%~dp0bin;%PATH%

rem Change the prompt
echo ;%PROMPT%; | find /C /I "(swift)" 1> NUL
if "%errorlevel%"=="1"  set "PROMPT=(swift) %PROMPT%"

TITLE Swift Tools Command Prompt
echo.
cmd /k
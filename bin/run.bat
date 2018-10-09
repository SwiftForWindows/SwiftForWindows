@echo off

set SFW_ORIG_PATH=%PATH%

rem Update the Path if RuntimeEnv is not contained
echo ;%PATH%; | find /C /I "%~dp0RuntimeEnv;" 1> NUL
if "%errorlevel%"=="1"  set PATH=%~dp0RuntimeEnv;%PATH%

set SFW_ARGC=0
for %%i in (%*) do set /A SFW_ARGC+=1
if %SFW_ARGC% == 0 (
  echo Run a program in the Swift runtime environment
  echo.
  echo Usage: run ^<swift-compiled-exe-file^>
)
set SFW_ARGC=

%*
set PATH=%SFW_ORIG_PATH%
set SFW_ORIG_PATH=

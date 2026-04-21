@echo off

REM ===========================================================================
REM Knowledge Discovery service uninstaller
REM ===========================================================================
pushd %~dp0

set COMPONENTS=( MediaServer, LicenseServer )

set VERSION=26.2.0
set INSTALL_BASE=C:\OpenText

set INSTALL_DIR=%INSTALL_BASE%\IDOLServer-%VERSION%

for %%i in %COMPONENTS% do (
	echo.
	echo Uninstalling %%i component...

	REM Remove Windows service
	net stop %%i
  timeout 5
	sc delete %%i

  if /i %%i==MediaServer (
    echo Remove the following path from your system PATH environment variable:
    echo %INSTALL_DIR%\MediaServer\libs\torch
  )
)

rd /s /q %INSTALL_DIR%

popd

echo.
echo Uninstall complete.
pause

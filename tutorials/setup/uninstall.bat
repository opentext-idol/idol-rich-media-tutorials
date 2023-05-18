@echo off

REM ===========================================================================
REM IDOL service uninstaller
REM ===========================================================================
pushd %~dp0

set COMPONENTS=( LicenseServer, MediaServer )

set VERSION=23.2.0
set INSTALL_BASE=C:\OpenText

set INSTALL_DIR=%INSTALL_BASE%\IDOLServer-%VERSION%

for %%i in %COMPONENTS% do (
	echo.
	echo Uninstalling %%i component...

	REM Remove Windows service
	net stop %%i
  timeout 5
	sc delete %%i
)

rd /s /q %INSTALL_DIR%

popd

echo.
echo Uninstall complete.
pause

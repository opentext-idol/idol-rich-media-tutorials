@echo off

REM ===========================================================================
REM IDOL service installer
REM ===========================================================================
pushd %~dp0

set COMPONENTS=( LicenseServer, MediaServer )

set VERSION=23.4.0
set INSTALL_BASE=C:\OpenText

set SOURCE_DIR=%HOMEPATH%\Downloads
set LICENSE_KEY=licensekey.dat

set SERVICE_PREFIX=OpenText-
set INSTALL_DIR=%INSTALL_BASE%\IDOLServer-%VERSION%

rd /s /q %INSTALL_DIR%
mkdir %INSTALL_DIR%

for %%i in %COMPONENTS% do (

  echo.
  echo Extracting %%i component...
  powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%SOURCE_DIR%\%%i_%VERSION%_WINDOWS_X86_64.zip', '%INSTALL_DIR%'); }"
  ren %INSTALL_DIR%\%%i_%VERSION%_WINDOWS_X86_64 %%i

  echo Installing %%i runtime dependencies...
  if exist %INSTALL_DIR%\%%i\vcredist_2017.exe (
    %INSTALL_DIR%\%%i\vcredist_2017.exe /install /passive /norestart
  )
  if exist %INSTALL_DIR%\%%i\runtime\vcredist_2017.exe (
    %INSTALL_DIR%\%%i\runtime\vcredist_2017.exe /install /passive /norestart
  )
  if exist %INSTALL_DIR%\%%i\runtime\vcredist_2019.exe (
    %INSTALL_DIR%\%%i\runtime\vcredist_2019.exe /install /passive /norestart
  )

  echo Configuring %%i as a Windows service
  %INSTALL_DIR%\%%i\%%i.exe -install
  sc config %%i DisplayName= "%SERVICE_PREFIX%%%i"
  sc config %%i Start= demand

  if /i %%i==LicenseServer (
    echo Copying license key file...
    copy /y %SOURCE_DIR%\%LICENSE_KEY% %INSTALL_DIR%\LicenseServer\licensekey.dat
  )
)

popd

echo.
echo Install complete.
pause

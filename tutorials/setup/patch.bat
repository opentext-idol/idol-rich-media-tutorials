@echo off

REM ===========================================================================
REM Patch IDOL installation with tutorial materials
REM ===========================================================================
pushd %~dp0

set VERSION=12.13.0
set INSTALL_BASE=C:\MicroFocus

set SERVICE_PREFIX=MicroFocus-
set INSTALL_DIR=%INSTALL_BASE%\IDOLServer-%VERSION%

REM ---------------------------------------------------------------------------
echo Copying process configuration files...

set CONFIG_DIR=%INSTALL_DIR%\MediaServer\configurations\tutorials
mkdir %CONFIG_DIR%
copy %~dp0..\introduction\*.cfg %CONFIG_DIR%
copy %~dp0..\showcase\id-card-ocr\*.cfg %CONFIG_DIR%

REM ---------------------------------------------------------------------------
echo Copying sample media files...

set MEDIA_DIR=%INSTALL_DIR%\sample_media
mkdir %MEDIA_DIR%
copy %~dp0..\showcase\id-card-ocr\*.png %MEDIA_DIR%

popd

echo.
echo Patch complete.
pause

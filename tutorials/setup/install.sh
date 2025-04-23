#!/usr/bin/env bash

# ===========================================================================
# Knowledge Discovery service installer
# ===========================================================================
pushd $(dirname "${0}") > /dev/null

COMPONENTS=( "LicenseServer" "MediaServer" )

VERSION="25.2.0"
INSTALL_BASE="~"

SOURCE_DIR="~/Downloads"
LICENSE_KEY="licensekey.dat"

INSTALL_DIR=$INSTALL_BASE"/IDOLServer-"$VERSION

rm -rf $INSTALL_DIR

for i in "${COMPONENTS[@]}"; do
	echo ""
	echo Extracting $i component...
  unzip -d $INSTALL_DIR $SOURCE_DIR"/"$i"_"$VERSION"_LINUX_X86_64.zip"
  mv $INSTALL_DIR"/"$i"_"$VERSION"_LINUX_X86_64" $INSTALL_DIR"/"$i

  if [ $i = "LicenseServer" ]; then
    echo Copying license key file...
    cp -f $SOURCE_DIR"/"$LICENSE_KEY $INSTALL_DIR"/LicenseServer/licensekey.dat"
  fi
done

echo Install complete.
popd > /dev/null

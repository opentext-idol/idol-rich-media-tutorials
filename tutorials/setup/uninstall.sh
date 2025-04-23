#!/usr/bin/env bash

# ===========================================================================
# Knowledge Discovery service uninstaller
# ===========================================================================
pushd $(dirname "${0}") > /dev/null

COMPONENTS=( "MediaServer" "LicenseServer" )

VERSION="25.2.0"
INSTALL_BASE="~"

INSTALL_DIR=$INSTALL_BASE"/IDOLServer-"$VERSION

for i in "${COMPONENTS[@]}"; do
	echo ""
	echo Uninstalling $i component...

	pushd $INSTALL_DIR"/"$i
	source stop-$(echo "$i" | awk '{print tolower($0)}').sh &
	wait
	popd

done

rm -rf $INSTALL_DIR

echo Uninstall complete.
popd > /dev/null

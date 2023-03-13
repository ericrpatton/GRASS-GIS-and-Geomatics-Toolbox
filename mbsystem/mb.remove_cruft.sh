#! /bin/bash

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT (no parameters required - the script does some MB-System garbage cleaning.\n"
	exit 0
fi

rm -fv *.grd *.cmd *.tif cleaning_grid*.mb-1

exit 0

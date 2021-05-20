#! /bin/bash
#
#
# list_gdal_proj.sh : A simple script to print out the raster resolution of
# a GDAL-readable raster.
#
# Last modified: December 2, 2019
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername \n"
	exit 1
fi

INPUT=$1

gdalinfo ${INPUT} | grep "PROJC.S"

exit 0

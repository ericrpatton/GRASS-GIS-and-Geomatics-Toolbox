#! /bin/bash
#
#
# list_gdal_res.sh : A simple script to print out the raster resolution of
# a GDAL-readable raster.
#
# Last modified: December 2,, 2019
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername \n"
	exit 1
fi

INPUT=$1

echo -e "\nPrinting resolution for raster map $INPUT:"
gdalinfo ${INPUT} | grep "Pixel" | awk '{print substr($4,2,8)}'

exit 0

#! /bin/bash
#
#
# brief_gdal_res.sh : A simple script to print out the raster resolution of
# a GDAL-readable raster, script-style.
#
# Last modified: December 2, 2019
#
#############################################################################

INPUT=$1

gdalinfo ${INPUT} | grep "Pixel" | awk '{print substr($4,2,3)}'

exit 0

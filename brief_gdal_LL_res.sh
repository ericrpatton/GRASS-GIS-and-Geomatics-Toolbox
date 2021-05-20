#! /bin/bash
#
#
# brief_gdal_LL_res.sh : A simple script to print out the raster resolution of
# a Geographic GDAL-readable raster, script-style.
#
# Last modified: September 25, 2020
#
#############################################################################

INPUT=$1

LL_RES=$(gdalinfo ${INPUT} | grep "Pixel" | awk -F'(' '{print $2}' | awk -F, '{printf "%3.6f\n", $1}')

# Assuming a spherical Earth as an approximation
METERS=$(echo "$LL_RES * 111319.44" | bc -l)

echo $METERS

exit 0

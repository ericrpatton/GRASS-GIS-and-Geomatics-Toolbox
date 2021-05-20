#! /bin/bash
#
#
# t2geo.sh: a quick script to take an input projected geotiff and inverse
# project it to geographic.
#
# Last modified: December 5, 2019
#
#############################################################################

INPUT=$1
SUFFIX=".`echo ${INPUT} | cut -d. -f2`"
OUTPUT="$(basename $INPUT $SUFFIX)_LL.tif"

gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -multi -wo NUM_THREADS=ALL_CPUS -wm 2500 -of "GTiff" ${INPUT} ${OUTPUT}

exit 0

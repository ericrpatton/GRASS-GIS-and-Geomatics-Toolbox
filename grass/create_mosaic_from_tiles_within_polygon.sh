#!/bin/bash

# This script was used to select all NTS CDEM rasters from a master index
# shapefile that fall within the current Grass region.

# The first parameter to the script is a master vector file containing
# polygons that will act as a selection mask for the output mosaic.
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

TILES=$1

# The script assumes that the output bounding box ends with the suffix "_Extent"
OUTPUT_REGION=$2
OUTPUT_BASE="`basename $OUTPUT_REGION _Extent`"
OUTPUT_TILES="${OUTPUT_BASE}_Tiles"
GRIDDING_LIST="${OUTPUT_BASE}_Gridding_List.txt"

v.in.region output=${OUTPUT_REGION} --o --v
v.select ainput=${TILES} binput=${OUTPUT_REGION} output=${OUTPUT_TILES} --o --v

# Assumes that the second column of the master vector tiles file is a column
# containing the name of a raster tile
v.db.select map=${OUTPUT_TILES} | awk -F'|' '{print $2}' > ${GRIDDING_LIST}
for ITEM in `cat ${GRIDDING_LIST}` ; do g.list type=rast pat="*${ITEM}*" | awk 'BEGIN {ORS=","} {print $1}' ; done > tmp
sed 's/,$//' tmp > ${GRIDDING_LIST}
r.patch in=`cat ${GRIDDING_LIST}` out=${OUTPUT_BASE} --o --v

exit 0

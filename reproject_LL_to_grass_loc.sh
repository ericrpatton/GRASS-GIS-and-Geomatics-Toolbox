#! /bin/bash
#
#
# reproject_LL_to_grass_loc.sh: A simple script to reproject an input raster to
# the current GRASS location projection.
#
# Last modified: September 25, 2020
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathy_filename [resolution]\n"
	exit 1
fi

INPUT=$1
RES=$2
SUFFIX=".`echo ${INPUT} | cut -d. -f2`"
OUTPUT="$(basename $INPUT $SUFFIX)_reproj$SUFFIX"

# The script accepts a user-supplied raster resolution on the command line,
# but if none is given, it does a rough calculation of the Geographic
# resolution to meters using the script brief_gdal_LL_res.sh. Note: Using the
# second method probably will not give you a round integer resolution. 
if [ -z "$RES" ] ; then
	RES=$(brief_gdal_LL_res.sh ${INPUT})
fi

gdalwarp -t_srs "`g.proj -jf`" -tr ${RES} ${RES} -r cubic -wm 2500 -wo "MAX_CPUS=4" -multi -overwrite ${INPUT} ${OUTPUT}

exit 0


#! /bin/bash
#
#
# reproject_to_grass_loc.sh: A simple script to reproject an input raster to
# the current GRASS location projection.
#
# Last modified: October 27, 2022
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathy_filename\n"
	exit 1
fi

INPUT=$1
SUFFIX=".`echo ${INPUT} | cut -d. -f2`"
OUTPUT="$(basename $INPUT $SUFFIX)_reproj$SUFFIX"

# Getting the raster res using this script probably only works with projected
# geotiffs
RES=$(brief_gdal_res.sh ${INPUT})

NPROC=$(nproc)
gdalwarp -t_srs $(g.proj -jf | sed 's/+type=crs//') -tr ${RES} ${RES} -r cubic -wm 10000 -wo MAX_CPUS=${NPROC}" -multi ${INPUT} ${OUTPUT}

exit 0

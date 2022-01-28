#! /bin/bash
#
# INPUT should be a wildcard search pattern.
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=$1
RES=$2

for RASTER_MASK in `g.list type=rast pattern=${INPUT}` ; do
	echo -e "\n===================================="
	echo -e "\nWorking on raster map $RASTER_MASK...\n"
	g.region rast=$RASTER_MASK res=$RES -ap
	r.mask raster=$RASTER_MASK
	INPUT_RES=`echo $RASTER_MASK | cut -d'_' -f5`
	OUTPUT_BASE=`echo $RASTER_MASK | cut -d'_' -f4`
	OUTPUT_NAME="Slope_Tiles_${OUTPUT_BASE}_${RES}m_clipped"
	SLOPENAME="`basename ${RASTER_MASK} _${INPUT_RES}`_slope_${RES}m"
	r.mapcalc "$OUTPUT_NAME = $SLOPENAME" --o
	r.mask -r
done

exit 0

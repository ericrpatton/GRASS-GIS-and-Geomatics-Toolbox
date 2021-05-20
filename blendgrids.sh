##############################################################################
#
# MODULE:        blendgrids.sh for Grass 7.*
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at Canada dot ca>
# 
# PURPOSE:       To run r.mapcalc on a given list of Grass rasters,
#				 producing a series of weighted-average maps, from 10% to 90%
#				 proportion between both raster maps
#
# COPYRIGHT:    (c) 2020 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: December 3, 2020
#	by Author
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_a raster_b\n"
	exit 1
fi

RASTER_A=$1
RASTER_B=$2

A=1
B=0

echo -e "\nblendgrids.sh"
echo -e "=============\n"

for (( i=0; i<9; i++)) ; do
	A=$(echo "$A - 0.1" | bc | awk '{printf "%.1f", $1}')
	B=$(echo "$B + 0.1" | bc | awk '{printf "%.1f", $1}')
	
	echo -e "\nBlending grids ${RASTER_A} and ${RASTER_B} at ratios ${A} to ${B}...\n"
	r.mapcalc "WAvg_Overlap_${RASTER_A}_${A}_and_${RASTER_B}_${B} = (${RASTER_A} * ${A} + ${RASTER_B} * ${B})" --o 
done

exit 0

#
############################################################################
#
# MODULE:        r.cliprast_using_vectpolygons.sh for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       ...
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		  , 2021
# Last Modified:  , 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught! Exiting.\n" ; exit 1' 2 3 15

# Give a help message if one of a number of standard flags is passed.
if [ "$#" -ne 2 -o "$1" = "-H" -o "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ] ; then
	echo -e "\nUsage: r.cliprast_using_vectpolygons.sh vectorname rastername\n" 
	exit 0
fi	

VECTOR=$1
RASTER=$2
OUTPUT=${VECTOR}_rast
CLIPPED_RAST=${RASTER}_vectclipped

g.region vect=${VECTOR}
v.to.rast in=${VECTOR} out=${OUTPUT} use=val val=1 --o --v
r.mapcalc "$CLIPPED_RAST = if(${OUTPUT}, ${RASTER}, null())" --v --o 

[[ "$?" -eq 0 ]] && echo -e "\nCreated clipped output raster map ${CLIPPED_RAST}."

exit 0

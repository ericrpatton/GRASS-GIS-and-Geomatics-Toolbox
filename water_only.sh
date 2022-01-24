############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        water_only.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To produce a raster containing negative depths (i.e., water)
#				 only.
#				 
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 October 29, 2021
# Last Modified: October 29, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

INPUT=$1
OUTPUT=${INPUT}_water_only

r.mapcalc "${OUTPUT} = if(${INPUT} < 0.0, ${INPUT}, null())" --o --v && echo -e "\nProduced output map ${OUTPUT}.\n"

exit 0

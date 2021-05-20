############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        r.find_rasters_in_compregion.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To apply a histogram-equalized colourbar to a Grass raster,
#				 and recreate the coloured, shaded-relief raster from it.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 May 18, 2021
# Last Modified: May 18, 2021
#
#############################################################################

# NOTE: This script assumes you have already set the  Grass computational region
# to the area of interest.

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

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT wildcard_pattern \n"
	exit 1
fi

[ -f "compregion_rasterlist.txt" ] && rm compregion_rasterlist.txt
[ -f "compregion_patching_list.txt" ] && rm compregion_patching_list.txt

PATTERN=$1

for MAP in $(g.list type=rast pattern="${PATTERN}") ; do
	CELL_COUNT=$(r.univar map=${MAP} -g | grep "^n=" | cut -d'=' -f2)
	
	[ ${CELL_COUNT} -gt 1 ] && echo ${MAP} && echo ${MAP} >> compregion_rasterlist.txt
done

cat compregion_rasterlist.txt | awk 'BEGIN {ORS=","} {print $1}' | sed 's/,$//' > compregion_patching_list.txt

echo -e "\nDone."

exit 0

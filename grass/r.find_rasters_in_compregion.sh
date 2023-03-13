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
# PURPOSE:       To print a list of rasters whose region intersect that of the
# current computational region; also formats this list into a csv string suitable
# for use in r.patch.
#				 
#
# COPYRIGHT:     (c) 2021-2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 May 18, 2021
# Last Modified: February 27, 2023
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
	echo -e "\nusage: $SCRIPT rastername \n"
	exit 1
fi

MAP=$1

CELL_COUNT=$(r.univar map=${MAP} -g | grep "^n=" | cut -d'=' -f2)
	
[ ${CELL_COUNT} -gt 1 ] && echo ${MAP} | tee -a compregion_rasterlist.txt

awk 'BEGIN {ORS=","} {print $1}' compregion_rasterlist.txt 2>/dev/null | sed 's/,$//' > compregion_patching_list.txt

exit 0

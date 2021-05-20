#! /bin/bash
#
############################################################################
#
# MODULE:        get_grid_wesn.sh
# 
# AUTHOR(S):   	 Eric Patton 
# 
# PURPOSE:       To extract the west, east, south and north bounds of a GMT
#				 grid and output these to the command line.
#
# COPYRIGHT:     (C) 2019  by Eric Patton (eric.patton at canada dot ca)
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
#
# Last Modified: November 20, 2019
#
#############################################################################

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

GRID=$1

grdinfo ${GRID} > tmp.txt

WEST=$(grep x_min tmp.txt | awk '{print $3}')
EAST=$(grep x_max tmp.txt | awk '{print $5}')
SOUTH=$(grep y_min tmp.txt | awk '{print $3}')
NORTH=$(grep y_max tmp.txt | awk '{print $5}')

echo "${WEST}/${EAST}/${SOUTH}/${NORTH}"

rm tmp.txt

exit 0

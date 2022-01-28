#! /bin/bash
#
############################################################################
#
# MODULE:        v.get_grid_divisions for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       Computes the number of lat-long subdivisions to divide into the
#				 current geographic region into, and prints the v.mkgrid command
#				 that would produce this grid.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 25, 2021
# Last Modified: November 25, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)
REGION=$(mb.getregion)

WEST=$(echo $REGION | cut -d'/' -f1)
EAST=$(echo $REGION | cut -d'/' -f2)
SOUTH=$(echo $REGION | cut -d'/' -f3)
NORTH=$(echo $REGION | cut -d'/' -f4)

NS_EXTENT_DEG=$(ceil.sh $(echo "$NORTH - $SOUTH" | bc -l))
EW_EXTENT_DEG=$(ceil.sh $(echo "$EAST - $WEST" | bc -l))

# Number of rows is dwetermined by latitude, and since I am hard-coding a grid
# of 30-min intervals, we need to double the N-S extent. 
ROWS=$(($NS_EXTENT_DEG * 2))
COLS=$EW_EXTENT_DEG  
WEST_ROUNDED_DOWN=$(floor.sh $WEST)
SOUTH_ROUNDED_DOWN=$(floor.sh $SOUTH)

echo "v.mkgrid map=LL_grid grid=${ROWS},${COLS} position=coor coor=${WEST_ROUNDED_DOWN},${SOUTH_ROUNDED_DOWN} box=1:00:00,0:30:00 --o --v"

exit 0

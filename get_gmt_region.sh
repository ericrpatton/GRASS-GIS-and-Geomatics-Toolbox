#! /bin/bash
#
############################################################################
#
# MODULE:        get_gmt_region.sh
# 
# AUTHOR(S):   	 Eric Patton 
# 
# PURPOSE:       To query the current region and print the bounds in
#				 Geographic coordinates as input into GMT. 
#
# COPYRIGHT:     (C) 2013-2017 by Eric Patton 
#				 (Eric dot Patton at Canada dot ca)
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
#
# Last Modified: March 30, 2017
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program." 2>&1
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

g.region -bg > REGION.txt

WEST=`grep ll_w < REGION.txt | cut -d= -f2`
EAST=`grep ll_e < REGION.txt | cut -d= -f2`
SOUTH=`grep ll_s < REGION.txt | cut -d= -f2`
NORTH=`grep ll_n < REGION.txt | cut -d= -f2`

echo "$WEST/$EAST/$SOUTH/$NORTH"

# Cleanup
if [ -f "REGION.txt" ] ; then
	rm -f REGION.txt
fi

exit 0

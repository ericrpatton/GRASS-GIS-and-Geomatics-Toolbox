#! /bin/bash
#
############################################################################
#
# MODULE:        get_gmt_grid_corners.sh
# 
# AUTHOR(S):   	 Eric Patton 
# 
# PURPOSE:       To extract the UTM bounds of a GMT grid and output these to
#				 the command line.
#
# COPYRIGHT:     (C) 2013  by Eric Patton (epatton at nrcan dot gc dot ca)
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
#
# Last Modified: May 1, 2018
#
#############################################################################

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

GRID=$1
ZONE=$2

# Save min/max coordinates with enough precision

grdinfo ${GRID} --FORMAT_FLOAT_OUT=%.10g -C > tmp.txt

# Use inverse UTM projection to determine the long/lat  of the lower left and
# upper right corners

LL=`cut -f2,4 tmp.txt | mapproject -Ju${ZONE}/1:1 -F -C -I --FORMAT_GEO_OUT=-D | \
awk '{printf "%s/%s\n", $1, $2}'`

UR=`cut -f3,5 tmp.txt | mapproject -Ju${ZONE}/1:1 -F -C -I --FORMAT_GEO_OUT=-D | \
awk '{printf "%s/%s\n", $1, $2}'`

echo ${LL}/${UR}

exit 0

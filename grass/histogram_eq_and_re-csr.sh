############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        histogram_eq_and_re-csr.sh for Grass 7.x
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
# Created:		 January 28, 2021
# Last Modified: January 28, 2021
#
#############################################################################


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
	echo -e "\nusage: $SCRIPT rastername\n"
	exit 1
fi

INPUT=$1

# Note: The -b flag of r.csr means it expects the shade file to already be
# created.

r.colors map=${INPUT} color=bof_unb -e --v 
r.csr -b ${INPUT}

exit 0

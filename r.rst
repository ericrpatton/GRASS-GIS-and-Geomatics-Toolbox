#! /bin/bash
#
############################################################################
#
# MODULE:        r.rst for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       A shell wrapper for quickly creating a regualrized spline with
#				 tension (rst) interpolated surafce from an input raster using
#				 simple default parameters. Uses the native resolution of the
#				 input raster.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 3, 2021
# Last Modified: November 3, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT r.rst rastername \n"
	exit 1
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

INPUT=$1
TENSION=$2
RES=$(getres.sh ${INPUT})

[[ -z ${TENSION} ]] && TENSION=40

r.resamp.rst in=${INPUT} elevation=${INPUT}_ten${TENSION}.rst tension=${TENSION} ewres=${RES} nsres=${RES} --o --v 

exit 0

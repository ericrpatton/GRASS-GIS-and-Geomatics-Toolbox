#! /bin/bash
#
############################################################################
#
# MODULE:        raster_rename_prep.sh

# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <eric dot patton at canada dot ca>
# 
# PURPOSE:       This is a helper script for the Grass addon module
#				 g.rename.many. It prints the names of rasters found by the
#				 search pattern into a csv file twice to assist in easy
#				 renaming.
#		 		 
# COPYRIGHT:    (c) 2019-2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: November 25, 2019
#	by Author
#############################################################################	

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "ERROR: Enter a raster wildcard search pattern for renaming.\n"
	echo -e "\nusage: $SCRIPT rastername_pattern\n"
	exit 1
fi

PATTERN=$1

g.list type=raster mapset=. pat=${PATTERN} | sed -e "s/\(.*\)/\1,\1/g" > raster_names.csv

exit 0

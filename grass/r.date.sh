#! /bin/bash 
#
############################################################################
#
# MODULE:        r.date.sh 
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at NRCAN dot gc dot ca>
# 
# PURPOSE:       To query the creation time of a raster map and print the result
#				 to the command line.
#
# COPYRIGHT:    (c) January 24, 2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername\n"
	exit 0
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1

r.info -e ${INPUT} | grep date | cut -d'"' -f2

exit 0

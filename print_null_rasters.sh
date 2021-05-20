#! /bin/bash
#
#
# print_null_rasters.sh : A simple script to print out the filenames of Grass
# rasters that have NULL values as the raster range.
#
# Last modified: October 3, 2020
#
#############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT wildcard_pattern \n"
	exit 1
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1 

list_range.sh ${MAP} | grep NULL > /dev/null && echo ${MAP}

exit 0

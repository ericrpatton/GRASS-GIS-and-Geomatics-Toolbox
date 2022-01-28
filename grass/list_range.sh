#! /bin/bash
#
#
# list_range.sh : A simple script to print out the raster range of
# all raster datasets matching a wildcard search pattern.
#
# Last modified: October 2, 2020
#
#############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_name \n"
	exit 1
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1

echo -e "\nPrinting range for raster map $INPUT: \n"
r.info -r ${INPUT} 
echo "" 

exit 0

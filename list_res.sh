#! /bin/bash
#
#
# list_res.sh : A simple script to print out the raster resolution of
# all raster datasets matching a wildcard search pattern.
#
# Last modified: January 18, 2016
#
#############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT list_res.sh \n"
	exit 1
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1

echo -e "\nPrinting resolution for raster map $INPUT: \n" 
r.info -g $INPUT | grep res 
echo "" 

exit 0

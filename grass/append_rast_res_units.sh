#! /bin/bash
#
# append_rast_res_metres.sh: A simple script to append the input raster's
# resolution units (metres) into the raster filename.
#
# Last modified: September 29, 2020
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_filename\n"
	exit 1
fi

INPUT=$1
OUTPUT="${INPUT}m"

g.rename rast=${INPUT},${OUTPUT}

exit 0

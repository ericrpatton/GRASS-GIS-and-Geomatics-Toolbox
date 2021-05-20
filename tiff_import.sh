#! /bin/bash
#
#
# tiff_import.sh: A simple script to import all geotiffs in the current
# directory into the current GRASS project. Warning: The script does to
# projection checking beforehand.
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
trap 'echo -e "\n\n$SCRIPT:User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_name\n"
	exit 1
fi

FILE=$1
SUFFIX=".`echo ${FILE} | cut -d. -f2`"
OUTPUT="$(basename $FILE $SUFFIX)"
r.in.gdal in=${FILE} out=${OUTPUT} mem=10000 --o --v -o 

exit 0

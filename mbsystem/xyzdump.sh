#!/bin/bash
#
# xyzdump.sh - This script exports x,y,z triplets of longitude, latitude,
# and depth from an MB-System datalist into GRASS GIS raster format. The
# script accepts three parameters as input: the first (and required) parameter
# is an MB-System datalist containing the list of files to process; the
# second is the region or bounding box of the desired data in Lat-Long (i.e.,
# west/east/south/north; default is the entire world, except the poles); and
# the third parameter is the name of the output bathymetry xyz file.
# 
# Last modified: January 20, 2016
#
# CHANGELOG:	- Updated to include a brief help message if no parameters
#				  given on the command line. (01-20-2016)
#
#############################################################################

# Check to see if GRASS is running; abort if not.
if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 [region (W/E/S/N)] [output.txt]\n"
	exit 1
fi

echo -e "\n------------- ${SCRIPT} --------------"

DATALIST=$1
REGION=$2
OUTPUT=$3


#TO-DO: Write a case statement to handle all the expected input parameters
# Sanity-checking...
while [ -z ${DATALIST} ] ; do
	echo ""
	read -p "Enter an input datalist to continue! " DATALIST
	
done

[[ -z ${REGION} ]] && REGION="-180/180/-89/89"
[[ -z ${OUTPUT} ]] && OUTPUT=bathy.xyz

echo -e "\nExporting xyz bathymetry at the following rate:\n"
mblist -F-1 -I ${DATALIST} -R${REGION} -D2 | awk '{print $1, $2, -$3}' | proj $(g.proj -jf | sed 's/+type=crs//') | pv | awk '{print $1, $2, $3}' > ${OUTPUT}

exit 0 

#! /bin/bash
#
# Prints out just the name of the last raster in a 'g.list type=raster' listing. 
#
# Created: March 19, 2021
# Modified: January 27, 2022
#
# by Eric Patton
#
##############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\n$SCRIPT: Prints out just the name of the last raster in a 'g.list type=raster' listing."	
	exit 1
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

g.list type=rast mapset=. | tail -n1 

exit 0

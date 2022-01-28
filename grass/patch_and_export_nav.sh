#!/bin/bash
#
#	patch_and_export_nav.sh
#
#	This script amalgamtes a series of Grass vector maps, exports them to GMT
#	format, and inverse projects them to Geographic/WGS84 to prepare them for
#	plotting in GMT.
#
#   Last modified: June 22, 2016
#
#
#############################################################################

SCRIPT=`basename $0`

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Define cleanup procedures
exit_cleanup()
{
	if [ -f ${GRASS_OUTPUT} ] ; then
		rm -v ${GRASS_OUTPUT}
	fi
	
	if [ -f ${GMT_OUTPUT} ] ; then
		rm -v ${GMT_OUTPUT}
	fi
}

cleanup()
{
	if [ -f ${GRASS_OUTPUT} ] ; then
		rm -v ${GRASS_OUTPUT}
	fi
}	

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n"
	exit_cleanup
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks (signal list: trap -l):
trap "exitprocedure" 2 3 15

# Provide a help message if no arguments or a flag iѕ passed
if [ "$#" -eq 0 -o "$1" = "-H" -o "$1" = "-h" -o "$1" = "-help" -o "$1" = "--help" ] ; then
	echo -e "Usage: $SCRIPT navfile.txt\n"
	exit 0
fi

# Nav can be either a single file or a filename prefix; but don't embed
# special wildcard characters in the filename
NAV=$1 
PATCH_OUTPUT="All_${NAV}_nav"
GRASS_OUTPUT="${PATCH_OUTPUT}.gmt"
GMT_OUTPUT="`basename ${GRASS_OUTPUT} .gmt`_LL.gmt"

echo -e "\nPatching and exporting the following files: \n\n"
g.list type=vect pat=${NAV}* 
sleep 3

v.patch in=`g.list type=vect pat=${NAV}* sep=,` output=${PATCH_OUTPUT} --o --v
v.out.ogr in=${PATCH_OUTPUT} format="OGR_GMT" output=${GRASS_OUTPUT} --o --v
ogr2ogr -f "OGR_GMT" -t_srs "EPSG:4326" ${GMT_OUTPUT} ${GRASS_OUTPUT} -overwrite

cleanup

exit 0

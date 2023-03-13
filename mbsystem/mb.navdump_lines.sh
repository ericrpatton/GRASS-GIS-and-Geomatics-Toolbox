#!/bin/bash
#
# mb.navdump_lines.sh - A script to export decimated navigation from an
# MB-System datalist to projected coordinates of the current GRASS GIS
# database. The projection is automatically detected from g.proj settings.
# Intended to produce projected point navigation suitable for the creation of
# GRASS GIS vector line files.
#
# Last Modified: June 22, 2017
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# Define cleanup procedures

cleanup()
{
	echo "Removing temporary files if they exist:"

	if [ -f ${OUTPUT} ] ; then
		rm -v ${OUTPUT}
	fi
}

exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n" 
	cleanup	
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure ; exit 1' 2 3 15

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 output.txt [W/E/S/N/]\n"
	exit 0
fi


DATALIST=$1 
OUTPUT=$2
REGION=$3

# If the REGION variable is empty or NO, default to the whole world.
if [ -z "$REGION" -o "$REGION" == "NO" -o "$REGION" == "no" ] ; then
	REGION="-360/360/-90/90"
fi

# The -Z parameter in mbnavlist creates the line break delimiter. Proj will
# ignore this string if it is referenced in the -t flag. But it must be
# substitued for the "NaN NaN" string in order to be acceptable to the GRASS
# program v.in.lines.

echo -e "\nExporting navigation from MB-System bathymetry...please stand by.\n"
mbnavlist -F-1 -I ${DATALIST} -R${REGION} -OXY -D10 -Z'swathfile' | pv | proj -t'#' $(g.proj -jf | sed 's/+type=crs//') | awk '{print $1, $2}' | sed 's/#/NaN NaN/' > ${OUTPUT}

if [ "$?" -eq 0 ] ; then
	echo "Done!"
fi	

exit 0

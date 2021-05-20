#!/bin/bash
#
# mb.navdump_points - a script to export decimated navigation from an
# mb-system datalist to projected coordinates of the current GRASS GIS
# database. The projection is automatically detected from g.proj settings.
# Intended to produce projected point navigation suitable for the creation of
# GRASS GIS vector point files.
#
# Last modified: June 22, 2017
#
###############################################################################


if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Define cleanup procedures

cleanup()
{
	echo "Removing temporary files if they exist:"

	if [ -f ${OUTPUT} ] ; then
		rm -v ${OUTPUT}
	fi

	if [ -f "tempnav.txt" ] ; then
		rm -v tempnav.txt
	fi
}

exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n" 
	cleanup	
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure ; exit 1' 2 3 15

# Help message
if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help" ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 output.txt [W/E/S/N]\n"
	exit 0
fi

DATALIST=$1 
OUTPUT=$2 
REGION=$3  

# If the user did not specify a region, default to the whole world
if [ -z "$REGION" -o "$REGION" == "NO" -o "$REGION" == "no" ] ; then
	REGION="-360/360/-90/90"
fi

echo -e "\nExporting navigation from MB-System bathymetry...please stand by.\n"

mblist -F-1 -I ${DATALIST} -R${REGION} -OtXYHSL.F > tempnav.txt 
awk 'NR % 10 == 0 {print $7, $8, $9, $10, $11, $1"/"$2"/"$3"/"$4"/"$5"/"$6, $12}' tempnav.txt | pv | proj -E `g.proj -jf` |  awk '{printf "%s %0.6f %0.6f %0.2f %0.2f %0.2f %0.2f %0.3f %s\n", $9, $1, $2, $3, $4, $5, $6, $7, $8}' > ${OUTPUT}

if [ "$?" -eq 0 ] ; then
	echo -e "\nFinished!\n"
	rm tempnav.txt
fi

exit 0

#!/bin/bash
#
# import_xyz.sh - A simple script to import the xyz file created from
# xyzdump.sh into a GRASS GIS database. The script checks if an input file
# name was given; if not, it assumes the filename is bathy.xyz (xyzdump.sh
# creates a file with this default name if no output filename is assigned at
# runtime). If no gridding resolution is provided by the user, a default coarse
# resolution of 100m is assumed.
#
# Last modified: February 5, 2021
#
# CHANGELOG: - Made the gridding resolution a bash variable instead of
#			   hard-coding it. Added a message to inform user of current gridding
#			   resolution being used (01-20-2016)
#			 - Improved help message (02-20-2020)
#			 - Code cleanup (02-05-2021)
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT [xyzfile.xyz] [resolution]\n" ; exit 1
fi

#TO-DO: Write a case statement to handle all the expected input parameters
INPUT=$1
RES=$2

echo -e "\n------------- ${SCRIPT} --------------\n"

# Assign a default resolution and output filename to use if none was given on the command line.
[[ -z ${INPUT} ]] && INPUT=bathy.xyz
[[ -z ${RES} ]] && RES=1

OUTPUT="`basename ${INPUT} .xyz`_${RES}m"

echo -e "\n<<========== Using a gridding resolution of ${RES}m ==========>>\n"
echo ""

g.align.xyz in=${INPUT} sep=space res=${RES}

r.in.xyz in=${INPUT} sep=space output=${OUTPUT} percent=25 --v --o 

exit 0 

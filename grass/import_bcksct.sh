#!/bin/bash
#
# import_bcksct.sh - A simple script to import the xyz file created from
# bcksct_dump.sh into a GRASS GIS database. The script checks if an input file
# name was given; if not, it assumes the filename is bcksct.xyz (bcksct_dump.sh
# creates a file with this default name if no output filename is assigned at
# runtime).
#
# CAVEAT: The script hard-codes the gridding resolution, so the script will
# have to be checked each time it is run.
#
# Last modified: January 14, 2016
#
# CHANGELOG: - Made the gridding resolution a bash variable instead of
#			   hard-coding it. Added a message to inform user of current gridding
#			   resolution being used (01-20-2016)
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1

if [ -z ${INPUT} ] ; then
	INPUT=bcksct.xyz
fi	

OUTPUT=`basename ${INPUT} .xyz`
RES=5

echo -e "\n<<========== Using a gridding resolution of ${RES}m ==========>>\n"
echo ""

g.align.xyz in=${INPUT} sep=space res=${RES}

r.in.xyz in=${INPUT} sep=space output=${OUTPUT} percent=33 --v --o 

exit 0 

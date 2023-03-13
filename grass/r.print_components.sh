#! /bin/bash
#
#############################################################################
#
# MODULE:        r.print_components.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       This is a collection of script fragments that I use over and
# over, which should be sourced in scripts they are needed in.
#
# COPYRIGHT:     (c) 2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  February 28, 2023
# Last Modified:  February 28, 2023
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername\n"
	exit 0
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

INPUT=$1

r.info -e ${INPUT} | grep comments | awk -F'=' '{print $3}' | sed 's/\\//g' | sed 's/"//g' | awk 'BEGIN {RS=","} {print $1}'

exit 0

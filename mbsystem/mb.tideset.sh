############################################################################
#! /bin/bash
#
# MODULE:        mb.tideset.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       This script sets the mbset flags to use a tide file during
#				 processing.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  May 25, 2022
# Last Modified:  June 6, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 tidefile.txt\n"
	exit 0
fi

# Procedure for setting tides in MB-System:
#
# Export a decimated version of the nav from MB-System for use in Webtide. 
# A suitable file can be generated with this command:
#
# mblist -F-1 -I datalist.mb-1 -OXYJ -K1000 | pv > Nav_decimated_1000th.txt
# 
# Then load this file into Webtide and generate a track tidal prediction for
# this nav.  The tide file is then used as input into mbset:

DATALIST=$1

[[ -z ${DATALIST} ]] && DATALIST=datalist.mb-1

TIDEFILE=$2

# WebTide creates extra lines in the output we need to remove prior to
# processing in MB-System
NUMBER_OF_LINES=$(wc -l ${TIDEFILE} | cut -d' ' -f1)

# Reformat the columns from WebTide so they are way MB-System expects them.
awk -v lines=${NUMBER_OF_LINES} 'NR > 5 && NR < lines {print $4, $5, $6, $7, $8, $1}' ${TIDEFILE} > tmp && mv tmp ${TIDEFILE}

mbset -I ${DATALIST} -PTIDEMODE:1 -PTIDEFILE:${TIDEFILE} -PTIDEFORMAT:3 

exit 0

# ############################################################################
#! /bin/bash
#
# MODULE:        calc_avg_svp.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       A quick script to calculate the average sound spped value
#				 from a Kongsberg SIS .asvp file for use in the Knudsen client.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  September 3, 2022
# Last Modified:  September 3, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT filename.asvp\n"
	exit 0
fi

INPUT=$1
COUNT=$(wc -l ${INPUT} | cut -d' ' -f1)

# The Knudsen client software doesn't accept decimal values for sound speed.
TOTAL=$(awk 'NR > 1 {print $2}' ${INPUT} | paste -sd+ - | bc | awk '{printf "%d\n", $1}') 
AVERAGE=$(echo "scale=0 ; ${TOTAL} / ${COUNT}" | bc )

echo ${AVERAGE}

exit 0

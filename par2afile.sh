#! /bin/bash
#
############################################################################
#
# MODULE:        par2afile.sh for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       Parses a PAR file for the start and stop times of the
# navigation of a seismic instrument and outputs the time, lat and long of the
# nav file to a GSCA-formatted NAV file.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		  January 20, 2021
# Last Modified:  January 20, 2021
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT parfile navfile \n"
	exit 1
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

PARFILE=$1
NAVFILE=$2
OUTPUT="$(basename $PARFILE .PAR).afile"

# Since we are going to be appending the out $OUTPUT later on, remove it if it
# already exists.
[[ -f ${OUTPUT} ]] && rm ${OUTPUT}

for LINE in $(seq 1 $(wc -l ${PARFILE} | cut -d' ' -f1)) ; do
	START=$(awk -v line=$LINE 'NR == line {print $1}' ${PARFILE})
	STOP=$(awk -v line=$LINE 'NR == line {print $2}' ${PARFILE})
	
	sed -n "/${START}/,/${STOP}/p" ${NAVFILE} >> ${OUTPUT}

done

exit 0

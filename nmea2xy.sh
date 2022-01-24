#! /bin/bash
#
###################################################################################
#
# MODULE:        nmea2xy.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic) 
# 
# PURPOSE:       To format a raw NMEA navigation file into GSC-A 'A-format' (timestamp, y, x).
#		 Allows the user to enter in a NMEA nav filename, and extracts position
#                and time from the GPGGA string.   
#
# COPYRIGHT:     (C) 2008-2021 Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). You can redistribute it and/or modify it
#                under the terms of the GNU General Public License as
#                published by the Free Software Foundation; either version 3
#                of the License, or (at your option) any later version.  This
#                program is distributed in the hope that it will be useful,
#                but WITHOUT ANY WARRANTY; without even the implied warranty
#                of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
#                the GNU General Public License (GPL) for more details.  You
#                should have received a copy of the GNU General Public License
#                along with this program; if not, write to the Free Software
#                Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
#                02111-1307, USA.
#
# Date Created: August 20, 2008
#
# Last Modified: June 5, 2016 (Changed output to 1-sec interval instead of 10-sec)
#				Also cleaned up variable names and quoted them more
#				consistently.
#				- Created a generic version of the nmea2a.sh script to handle a
#				nmea output from any source, not just Regulus.
###################################################################################

SCRIPT=`basename $0`

# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" 2>&1
    exit 1
fi

# Capture Ctrl-C and similar breaks
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15


if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT nmeafile \n"
	exit 1
fi

INPUT=$1
SUFFIX=$(echo $INPUT | cut -d'.' -f2)
OUTPUT="$(basename $INPUT .$SUFFIX).nav"

# Check input parameter
while [ ! -f "$INPUT" ] ; do
	echo -e "\n$SCRIPT: Error: Specified navigation file doesn't exist!" 
	read -p "Re-enter an existing nmea file in the current directory: " INPUT
done	

# For cases where the only nav string in the nmea file is GPGGA or INGGA
awk -F, '$1 ~ /\$GPGGA/ || $1 ~ /\$INGGA/ {printf "%000006d %2.6f -%3.6f\n", $2, substr($3,1,2) + substr($3,3)/60, substr($5,2,2) + substr($5,4)/60}' ${INPUT} > ${OUTPUT}

# For cases where the only nav string in the nmea file is GPGLL
#awk -F, -v '$1 ~ /\$GPGLL/ {printf "%7d %2.6f -%3.6f\n", $6, substr($2,1,2) + substr($2,3)/60, substr($4,2,2) + substr($4,4)/60}'

exit 0

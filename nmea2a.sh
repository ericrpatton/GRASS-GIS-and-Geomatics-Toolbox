#! /bin/bash
#
###################################################################################
#
# MODULE:        nmea2a.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic) 
# 
# PURPOSE:       To format a raw NMEA navigation file into GSC-A 'A-format' (timestamp, y, x).
#		 Allows the user to enter in a NMEA nav filename, and extracts position
#                and time from the GPGGA string.   
#
# COPYRIGHT:     (C) 2008-2016 Eric Patton
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
###################################################################################

SCRIPT=`basename $0`

# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" 2>&1
    exit 1
fi

# Capture Ctrl-C and similar breaks
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15

INPUT=$1

# Check input parameter
while [ ! -f "$INPUT" ] ; do
	echo -e "\n$SCRIPT: Error: Specified navigation file doesn't exist!" 
	read -p "Re-enter an existing E file in the current directory: " INPUT
done	

# Extract Julian Day from filename - by convention Regulus navigation files
# embed the Julian Day in their filenames.
JULIAN_DAY=`echo ${INPUT} | awk -F. '{print substr($1,5,3)}'`

#echo -e "\nThe Julian day is $JULIAN_DAY."
#exit 0

# Extract the basename for use in the output filename.
A_BASENAME="`echo ${INPUT} | cut -d'.' -f1`_1s"

# Create the proper suffix from the provided e-file. 
E_SUFFIX=`echo ${INPUT} | cut -d. -f2`
A_SUFFIX=`echo ${E_SUFFIX} | tr 'E' 'a'`

# For cases where the only nav string in the nmea file is GPGGA
awk -F, -v JULIAN_DAY=$JULIAN_DAY '$1 ~ /\$GPGGA/ {printf "%9d  %2.6f  -%3.6f\n", JULIAN_DAY$2, substr($3,1,2) + substr($3,3)/60, substr($5,2,2) + substr($5,4)/60}' ${INPUT} > ${A_BASENAME}.${A_SUFFIX}

# For cases where the only nav string in the nmea file is GPGLL
#awk -F, -v JULIAN_DAY=$JULIAN_DAY '$1 ~ /\$GPGLL/ {printf "%9d %2.6f  -%3.6f\n", JULIAN_DAY$6, substr($2,1,2) + substr($2,3)/60, substr($4,2,2) + substr($4,4)/60}'

exit 0

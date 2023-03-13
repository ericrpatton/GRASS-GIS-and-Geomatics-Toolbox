#########################################################################################
#! /bin/bash
#
# MODULE: 	nav2par.sh
#
# AUTHOR: 	Eric Patton, Geological Survey of Canada (Atlantic)
#
# PURPOSE:	To find the breaks within a nav file and write these to a parameter
# file acceptable for upload into Expedition Database.
#
# COPYRIGHT:    (C) 2021-2022 by Eric Patton
#
#           This program is free software under the GNU General Public
#           License (>=v3). You can redistribute it and/or modify it 
#		    under the terms of the GNU General Public License as 
#		    published by the Free Software Foundation; either version 3 
#		    of the License, or (at your option) any later version.
# 		    This program is distributed in the hope that it will be useful,
#		    but WITHOUT ANY WARRANTY; without even the implied warranty of
#		    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#		    GNU General Public License (GPL) for more details.
#	 	    You should have received a copy of the GNU General Public License
#		    along with this program; if not, write to the
#		    Free Software Foundation, Inc.,
#		    59 Temple Place - Suite 330,
#		    Boston, MA  02111-1307, USA.	
# 	
# Created: January 18, 2021
# Last Modified: August 31, 2021
#
#########################################################################################

# Input format expected: A finalized nav file consisting of three
# space-delimited columns: timestamp, latitude, and longitude.
#			 Ex: 

SCRIPT=$(basename $0)

# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" 2>&1
    exit 1
fi

# Capture Ctrl-C and similar breaks
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 2 ] ; then
	echo -e "\nusage: $SCRIPT navfile cruise_name\n"
	exit 1
fi

NAVFILE=$1
CRUISE=$2
PARFILE="${CRUISE}.PAR"

awk -v NAVFILE=${NAVFILE} ' 

BEGIN { COUNTER = 0 } 

# MAIN BODY
NR > 1 {
	
	if (NF > 2 ) {
		SECTION_START_TIME[COUNTER] = $1
		COUNTER++
	}

else { 
	print SECTION_START_TIME[0] " " SECTION_START_TIME[COUNTER -1]
	delete SECTION_START_TIME 

	COUNTER = 0 
	}
}

END { print SECTION_START_TIME[0] " " SECTION_START_TIME[COUNTER -1] }

' ${NAVFILE} > ${PARFILE}

[[ -f ${PARFILE} ]] && echo -e "\nDone.\n"

exit 0

#########################################################################################
#! /bin/bash
#
# MODULE: 	nav2par.sh
#
# AUTHOR: 	Eric Patton, Geological Survey of Canada (Atlantic)
#
# PURPOSE:  TO extract parameter file times from a completed nav file.	
# 	  	    
# COPYRIGHT: (C) 2010-2020 by Eric Patton
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
# Created:  April 15, 2010
# Last Modified: August 26, 2020
#
#########################################################################################

# Input format expected: Text file consisting of space-delimited columns of data
#			 Ex: 146133010 45.340056 -65.342710		
#
# NOTE: This script does not attempt to detect the gaps in the nav file. For
# that, use the script afile2nav.sh

SCRIPT=$(basename $0)
INPUT=$1
OUTPUT=`echo $INPUT | cut -d'.' -f1`.PAR


# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" 2>&1
    exit 1
fi

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT afile \n"
	exit 1
fi

# Capture Ctrl-C and similar breaks
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15

echo -e "\nWriting nav sections to output PAR file...\n"

awk 'BEGIN { COUNTER = 0 } NR != 1 {
	if (NF == 4) {
		COUNTER++
		TIMESTAMP[COUNTER] = $1
	}

	else {
		print TIMESTAMP[1], TIMESTAMP[COUNTER]
		COUNTER = 0
		delete TIMESTAMP
	}

}
	
END { print TIMESTAMP[1], TIMESTAMP[COUNTER]  }' $INPUT > $OUTPUT

if [ -f "$OUTPUT" ] ; then
	echo -e "Finished writing output PAR file $OUTPUT.\n"
fi

exit 0

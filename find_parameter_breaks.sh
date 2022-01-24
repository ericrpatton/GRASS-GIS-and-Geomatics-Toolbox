#########################################################################################
#! /bin/bash
#
# MODULE: 	find_parameter_breaks.sh
#
# AUTHOR: 	Eric Patton, Geological Survey of Canada (Atlantic)
#
# PURPOSE:	To find the breaks within a parameter file and write these to a text
# file.
#
# COPYRIGHT:    (C) 2021 by Eric Patton
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
# Last Modified: January 19, 2021
#
#########################################################################################

# Input format expected: Text file consisting of space-delimited columns of
# timestamps.
#			 Ex: 146133010 146142035

SCRIPT=$(basename $0)

# Check if we have awk.
if [ ! -x "`which awk`" ] ; then
    echo "$SCRIPT: awk required, please install awk or gawk first" 2>&1
    exit 1
fi

# Capture Ctrl-C and similar breaks
trap 'echo -e "\n\nUser break! Exiting.\n" ; exit 1' 2 3 15

# The method used to compare each timestamp in turn will be to separate out
# the julian day, hours, minutes, and seconds from the timestamp string using
# the substr() function in awk. All of these will be converted to seconds and
# summed to give one value for the timestamp in seconds from the beginning of
# the year where Jan 1 00:00:00 = 0. Then this value will be stored in an
# array and compared to the next timestamp in sequence. Each ROW_NUMBER in the
# input file will have subtracted from it the timestamp from the previous ROW_NUMBER.
# Any difference greater than the threshold value will flag a line break. The
# threshold value will not be hard-coded, but will be variable and if not
# given on the command line as an argument to the script, it will be assumed
# to be 1 minute.

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT [parameter_file cruise_name time_threshold [60] ]\n"
	exit 1
fi

# See if an parameter file, cruise name, and time threshold were passed as parameters; if so, 
# use them, if not, prompt.

case "$#" in

0) read -p "Enter name of parameter file to check: " PARFILE
read -p "Enter the cruise number: " CRUISE 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

1) PARFILE=$1 
read -p "Enter the cruise number: " CRUISE

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

2) PARFILE=$1 ; CRUISE=$2 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

3) PARFILE=$1 ; CRUISE=$2 ; THRESHOLD=$3

;;

*) echo -e "\n$SCRIPT: Error: program syntax is: find_parameter_breaks.sh parameter_file_name cruise_number time_threshold"
   echo -e "Only zero to three parameters are accepted.\n" 
   exit 1	
;;

esac

# TO-DO:
# Write more sanity checks for the starting arguments given to the script,
# for example, trap cases where null strings are passed for each input argument.

OUTPUT="${CRUISE}.PAR"

if [ -z "$THRESHOLD" ] ; then
	THRESHOLD=60
fi


awk -v PARFILE=$PARFILE -v THRESHOLD=$THRESHOLD '

# Initialize variables. Set PREV_TIME_ALL_SECONDS to a number high enough that
# when subtracted from TIME_ALL_SECONDS in the very first ROW_NUMBER, a negative number 
# is produced, passing the first THRESHOLD check.

{
	
# Use substr() to convert each portion of the input timestamp into seconds
# - First three digits are the julian day
# - Next two digits are the hours of the day
# - Next two digits are minutes of the hour
# - Last two digits are seconds of the minute

START_TIME_DAYS = substr($1,1,3)
START_TIME_HOURS = substr($1,4,2)
START_TIME_MINUTES =substr($1,6,2) 
START_TIME_SECONDS = substr($1,8,2)

START_TIME_ALL_SECONDS = START_TIME_SECONDS + (START_TIME_MINUTES * 60) + (START_TIME_HOURS *3600) + (START_TIME_DAYS * 86400)

END_TIME_DAYS = substr($2,1,3)
END_TIME_HOURS = substr($2,4,2)
END_TIME_MINUTES =substr($2,6,2)
END_TIME_SECONDS = substr($2,8,2)

END_TIME_ALL_SECONDS = END_TIME_SECONDS + (END_TIME_MINUTES * 60) + (END_TIME_HOURS *3600) + (END_TIME_DAYS * 86400)

# This check produces a large negative number on the first record of the file

TIME_DIFF = START_TIME_ALL_SECONDS - PREV_RECORD_TIME_ALL_SECONDS

if (TIME_DIFF <= THRESHOLD) {

	SECTION_START_TIMES[COUNTER] = $1
	SECTION_END_TIMES[COUNTER] = $2
	}

else { 
	print SECTION_START_TIMES[0] " " SECTION_END_TIMES[COUNTER -1]
	delete SECTION_START_TIMES 
	delete SECTION_END_TIMES

	COUNTER = 0 
	SECTION_START_TIMES[COUNTER] = $1
	SECTION_END_TIMES[COUNTER] = $2
	
	}

COUNTER++
PREV_RECORD_TIME_ALL_SECONDS = END_TIME_ALL_SECONDS

}

END { print SECTION_START_TIMES[0] " " SECTION_END_TIMES[COUNTER -1] }

' ${PARFILE} | tee -a ${OUTPUT}

exit 0

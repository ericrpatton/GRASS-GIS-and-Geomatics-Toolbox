#########################################################################################
#! /bin/bash
#
# MODULE: 	afile2nav.sh
#
# AUTHOR: 	Eric Patton, Geological Survey of Canada (Atlantic)
#
# PURPOSE:	To prepare a *cleaned* afile for upload into the Expedition Database.
# 	  	    Reads through the input file and inserts a line break at every point in the
#	   	    file where a difference between adjacent timestamps is more than some user-defined 
#	   	    threshold value. Writes the cruise name and ROW_NUMBER count at the beginning 
#         	of each section.
#
# COPYRIGHT:    (C) 2008-2022 by Eric Patton
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
# Created: October 24, 2008
# Last Modified: January 20, 2022
#
#########################################################################################

# Input format expected: Text file consisting of space-delimited columns of data
# in the format of time, latitude, longitude (ex: 146133010 45.340056 -65.342710)

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
# afile have subtracted from it the timestamp from the previous ROW_NUMBER.
# Any difference greater than the threshold value will flag a line break. The
# threshold value will not be hard-coded, but will be variable and if not
# given on the command line as an argument to the script, it will be assumed
# to be 1 minute.

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT afile cruise_name [time_threshold [60]]\n"
	exit 1
fi

# See if an afile, cruise name, and time threshold were passed as parameters; if so, 
# use them, if not, prompt.

case "$#" in

0) read -p "Enter name of navigation A-File to check: " AFILE 
read -p "Enter the cruise number: " CRUISE 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

1) AFILE=$1 
read -p "Enter the cruise number: " CRUISE

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

2) AFILE=$1 ; CRUISE=$2 

read -p "Enter the time threshold in seconds: " THRESHOLD 

;;

3) AFILE=$1 ; CRUISE=$2 ; THRESHOLD=$3

;;

*) echo -e "\n$SCRIPT: Error: program syntax is: afile2nav.sh afile_name cruise_number time_threshold"
   echo -e "Only zero to three parameters are accepted.\n" 
   exit 1	
;;

esac

# TO-DO:
# Write more sanity checks for the starting arguments given to the script,
# for example, trap cases where null strings are passed for each input argument.

NAVFILE="${CRUISE}.NAV"

if [ -z "$THRESHOLD" ] ; then
	THRESHOLD=60
fi

echo -e "\nScanning afile for breaks..."

awk -v AFILE=$AFILE -v CRUISE=$CRUISE -v THRESHOLD=$THRESHOLD '

# Initialize variables. Set PREV_TIME_ALL_SECONDS to a number high enough that
# when subtracted from TIME_ALL_SECONDS in the very first ROW_NUMBER, a negative number 
# is produced, passing the first THRESHOLD check.

BEGIN { STREAK = 0 ; PREV_TIME_ALL_SECONDS = 32000000 } {

TIMESTAMPS[STREAK] = $1 ; LATITUDE[STREAK] = $2 ; LONGITUDE[STREAK] = $3

# Use substr() to convert each portion of the input timestamp into seconds
# - First three digits are the julian day
# - Next two digits are the hours of the day
# - Next two digits are minutes of the hour
# - Last two digits are seconds of the minute

TIME_DAYS = substr(TIMESTAMPS[STREAK],1,3)
TIME_HOURS = substr(TIMESTAMPS[STREAK],4,2)
TIME_MINUTES =substr(TIMESTAMPS[STREAK],6,2)
TIME_SECONDS = substr(TIMESTAMPS[STREAK],8,2)

TIME_ALL_SECONDS = TIME_SECONDS + (TIME_MINUTES * 60) + (TIME_HOURS *3600) + (TIME_DAYS * 86400)

TIME_DIFF[STREAK] = (TIME_ALL_SECONDS - PREV_TIME_ALL_SECONDS)


if (TIME_DIFF[STREAK] > THRESHOLD) {

	# Store the current record, which represents the breakpoint between timestamps into variables
	# where it will be be used again as the first record in the next block of timestamps later on.
	BREAK_TIME = TIMESTAMPS[STREAK] ; BREAK_LAT = LATITUDE[STREAK] ; BREAK_LONG = LONGITUDE[STREAK] ; BREAK_DIFF = TIME_DIFF[STREAK]
	
	print CRUISE " " STREAK
		
	for (i=0; i<STREAK; i++) {
		# I dont think I need to include the time difference in the fourth
		# column, so Im commenting that out below. Revert back to it if
		# Curation asks for it.
		# print TIMESTAMPS[i], " "LATITUDE[i], " "LONGITUDE[i], TIME_DIFF[i]
		
		print TIMESTAMPS[i], " "LATITUDE[i], " "LONGITUDE[i]
	}
	
	STREAK = 0
	
	# Clear the arrays, and insert the breakpoint record as the first row in the next section
	delete TIMESTAMPS ; delete LATITUDE ; delete LONGITUDE ; delete TIME_DIFF
	TIMESTAMPS[STREAK] = BREAK_TIME ; LATITUDE[STREAK] = BREAK_LAT ; LONGITUDE[STREAK] = BREAK_LONG ; TIME_DIFF[STREAK] = BREAK_DIFF
	
}

STREAK++ 
PREV_TIME_ALL_SECONDS = TIME_ALL_SECONDS
}

END { print CRUISE " " STREAK

for (i=0; i<STREAK; i++) {
	#print TIMESTAMPS[i], " "LATITUDE[i], " "LONGITUDE[i], " "TIME_DIFF[i]
	print TIMESTAMPS[i], " "LATITUDE[i], " "LONGITUDE[i]

}

}' ${AFILE} >> ${NAVFILE}

if [ -f "$NAVFILE" ] ; then
	echo -e "\nFinished writing NAV file $NAVFILE."
fi

exit 0

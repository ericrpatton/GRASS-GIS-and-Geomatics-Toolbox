############################################################################
#! /bin/bash 
#
# MODULE:  julian_time_math_for_kea.sh

# DESCRIPTION: This module performs addition or subtraction on the timestamps in
# a navigation file (customized for Knudsen KEA files), according to the amount
# provided by the user on the command line. All other columns of data are
# printed out unchanged, along with the modified timestamps. The user will have
# to customize the script to parse the input file according to how many columns
# of input there are - the Knudsen client software allows the user to define the
# amount and types of data output in a KEA file, so there is no standard
# structure to the file by default.
#
# Date Created: Jan 21, 2021
# Last Modified: Jan 21, 2021
#
# COPYRIGHT:    (c)  by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
##############################################################################

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$#" -ne 3 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT navfile operation[a|s] value\n"
	exit 1
fi

#Assuming a comma-delimited input file such as a Knudsen KEA file; modify as
# necessary for other nav input delimiters.
INPUT=$1
OUTPUT="Knudsen_$(basename $INPUT .kea)_mod_timestamp.afile"
SEP=","
MODE=$2
VALUE=$3

LIST_LENGTH=$(awk '{print NR}' ${INPUT}  | tail -n1)
echo -e "\nProcessing $LIST_LENGTH timestamps...please standby..."
sleep 1.5

awk -F${SEP} -v mode=${MODE} -v value=${VALUE} 'NR > 1 {
	YEAR=substr($1,5,4)
	MONTH=substr($1,3,2)
	DAY=substr($1,1,2)
	HOUR=substr($2,1,2)
	MIN=substr($2,3,2)
	SEC=substr($2,5,2)
	RAWDATE=YEAR" "MONTH" "DAY" "HOUR" "MIN" "SEC
	UNIXTIME=mktime(RAWDATE)
	JULIAN_DAY=strftime("%j", UNIXTIME) 
	
	TIME_ALL_SECONDS=(SEC + (MIN *60) + (HOUR *3600) + (JULIAN_DAY * 86400))
	
	if ( mode == "A" || mode == "a" ) 
		FINAL_TIME_SECONDS = TIME_ALL_SECONDS + value
	else
		FINAL_TIME_SECONDS = TIME_ALL_SECONDS - value
	
	FINAL_TIME_DAYS=FINAL_TIME_SECONDS / 86400
	SECONDS_REMAINDER=FINAL_TIME_SECONDS % 86400
	FINAL_TIME_HOURS=sprintf("%02d", int(SECONDS_REMAINDER / 3600))
	FINAL_TIME_MIN=sprintf("%02d", ((SECONDS_REMAINDER % 3600) / 60))
	FINAL_TIME_SECONDS=sprintf("%02d", ((SECONDS_REMAINDER % 3600) % 60))
	
	ANSWER=int(FINAL_TIME_DAYS) FINAL_TIME_HOURS FINAL_TIME_MIN FINAL_TIME_SECONDS
	
	printf "%i %s %s\n", ANSWER, $16, $17

	}' ${INPUT} | uniq -w9 | sed 's/N//' | sed 's/W//' | awk '$2 != 0 && $3 != 0 {printf "%i %2.6f %2.6f\n", $1, $2, -$3}' | tee ${OUTPUT}


exit 0

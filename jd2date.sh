#! /bin/bash

# Convert a given Julian day of the year (i.e., JD127) to the calendar day:
#
##############################################################################

SCRIPT=`basename $0`

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT julian_day_to_convert \n"
	exit 1
fi


JD=$1
date -d "`date '+%Y'`-01-01 $JD days" '+%Y/%m/%d'

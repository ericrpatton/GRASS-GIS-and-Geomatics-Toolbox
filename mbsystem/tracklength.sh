#! /bin/bash
#
# MODULE:        tracklength.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       A quick script to print out the tracklength of a datalist from
#				 and mbinfo file in the current directory.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 27, 2022
# Last Modified:  AUgust 21, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT mbinfo_filename.txt \n"
	exit 1
fi

FILE=$1

[[ -z ${FILE} ]] && FILE=mbinfo.txt

cat $FILE | grep "Total Track Length" | awk '{print $4, "km"}'

exit 0

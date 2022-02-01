#! /bin/bash
#
# Prints out just the name of the most-recently modified regular file in the 
# current directory. Note this script only prints files, not directories.
#
# Created: January 27, 2022
# Modified: February 1, 2021
#
# by Eric Patton
#
##############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\n$SCRIPT: Prints out just the name of the most-recently modified regular file in the currecnt directory."
	exit 1
fi

PATTERN=$1

ls -lprt ${PATTERN} | grep -v / | tail -n1 | awk '{print $9}'

exit 0

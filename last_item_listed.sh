#! /bin/bash
#
# Prints out just the name of the last file` listed in an ls -l directory
# listing. 
#
# Created: March 19, 2021
# Modified: January 27, 2022
#
# by Eric Patton
#
##############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\n$SCRIPT: Prints out just the name of the last file listed in an ls -l directory listing. \n"
	exit 1
fi

ls -l | tail -n1 | awk '{print $9}'

exit 0

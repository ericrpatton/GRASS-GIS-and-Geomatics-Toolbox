#! /bin/bash
#
############################################################################
#
# MODULE:        create_timestamp_proof.sh 
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To sign an input file with my GPG key, and create an
# OpenTimestamp proof of the GPG-signed file.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 27, 2022
# Last Modified:  November 4, 2022
#
#############################################################################

SCRIPT=$(basename $0)

INPUT=$1

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nTimestamps a GPG-signed file using OpenTimestamps."
	echo -e "usage: $SCRIPT filename\n"
	exit 1
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

# Check if we have ots installed

OTS_CHECK=$(which ots)

if [[ -z ${OTS_CHECK} ]] ; then 
	echo -e "\nERROR: $SCRIPT: Please install ots from https://github.com/opentimestamps/opentimestamps-client to continue."
	exit 1
fi

# DO IT

gpg -ab ${INPUT} 
ots stamp ${INPUT}.asc

[[ -f "${INPUT}.asc.ots" ]] ; echo -e "\nDone."

exit 0

#! /bin/bash
#
############################################################################
#
# MODULE:        create_timestamp_proof.sh 
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To compress a file using lzip, create a SH256 checksum of that
# file, sign the checksum with my GPG key, and create an OpenTimestamp proof of
# the GPG-signed SHA256 checksum.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 27, 2022
# Last Modified:  January 27, 2022
#
#############################################################################

SCRIPT=$(basename $0)

INPUT=$1

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nTimestamps a compressed, GPG-signed checksum of a file using OpenTimestamps."
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

lzip -vv ${INPUT}
sha256sum ${INPUT}.lz > ${INPUT}.lz.sha256
gpg -ab ${INPUT}.lz.sha256 
ots stamp ${INPUT}.lz.sha256.asc

[[ -f "${INPUT}.lz.sha256.asc.ots" ]] ; echo -e "\nDone."

exit 0

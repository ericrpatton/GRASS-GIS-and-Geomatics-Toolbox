#!/bin/bash
#
#
# xyzsplit.sh - A script to split ascii files into 2GB chunks for easier
# import into GIS programs. The PREFIX (the second input paramter), is an
# arbitrary text string prepended to the output filename. 
#
# Last modified: March 28, 2017
#
#############################################################################


INPUT=$1
PREFIX=$2

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

# Sanity-checking...
if [  ] ; then
	echo -e "\nusage: $SCRIPT xyzfilename.txt output_prefixname\n"
	exit 1
fi

if [ "$#" -eq 0 -o $1 == "-H" -o $1 == "-h" -o $1 == "-help" -o $1 == "--help"  ] ; then
	echo -e "\nusage: $SCRIPT xyzfilename.txt output_prefixname\n"
	exit 1
fi

echo -e "\nSplitting $1 into 2GB chunks...please standby.\n"
split -C2GB --additional-suffix=.xyz --verbose ${INPUT} ${PREFIX}

exit 0

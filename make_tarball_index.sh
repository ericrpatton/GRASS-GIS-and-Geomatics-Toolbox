#! /bin/bash
#
############################################################################
#
# MODULE:        make_tarball_index.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       This script reads through a tarball using the -t flag and
# creates an index of the files contained within for easy reference.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 30, 2022
# Last Modified:  January 30, 2022
#
#############################################################################
SCRIPT=$(basename $0)

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT tarfilename"
	echo "Creates an index listing of the given tarball in the current directory."
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

INPUT=$1

tar -tnvf ${INPUT} | awk '{print $6}' | tee ${INPUT}.idx 

exit 0

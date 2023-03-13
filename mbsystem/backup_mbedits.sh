#!/bin/bash
#
############################################################################
#
# MODULE:        backup_mbedits.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To use rsync to recursively backup all edit save files (*.esf)
#				 that exist in the current directory, and copy them to the
# 				 specified backup location.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 October 31, 2021
# Last Modified: October 31, 2021
#
#############################################################################

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT destination_dirname \n"
	exit 1
fi

DESTINATION=$1

rsync -ahrvP --prune-empty-dirs --include='*.esf*' --include='*/' --exclude='*' . ${DESTINATION}

exit 0

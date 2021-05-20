############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        mb.datalist_this_region.sh for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To create a datalist from the MB-System files in the current
# directory using the current Grass computational region extents.
#				 
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 March 18, 2021
# Last Modified: March 18, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT [datalist_name] \n"
	exit 1
fi

# Use the MB-System standard datalist.mb-1 if no datalist was given on the
# command line.
DATALIST=$1
[ -z ${DATALIST} ] && DATALIST="datalist.mb-1"

mbdatalist -F-1 -I ${DATALIST} -R$(mb.getregion) | tee cleaning_$(date '+%b%d_%Y').mb-1

exit 0

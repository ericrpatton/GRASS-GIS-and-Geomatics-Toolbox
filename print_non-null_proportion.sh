#! /bin/bash
#
############################################################################
#
# MODULE:        print_non-null_proportion.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       A simple script to calculate and print the proportion of
# non-null cells to null cells in a raster map. The script expects as input a
# text file containing raster statistics as produced by 'r.univar -g'.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 December 13, 2021
# Last Modified: December 13, 2021
#
#############################################################################

SCRIPT=$(basename $0)

FILE=$1

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_stats.txt \n"
	exit 1
fi

eval $(cat ${FILE})
echo "scale=6 ; (($n / $null_cells) * 100)" | bc -l

exit 0

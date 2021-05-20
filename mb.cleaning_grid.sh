############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        mb.cleaning_grid.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To create a quick grid file for editing in mbgrdviz. It uses
# the processed version of the input datalist, so make sure to use the raw
# datalist as the parameter.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 February 25, 2021
# Last Modified: February 25, 2021
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

if [ "$#" -gt 2 -o "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist_name [ resolution ] \n"
	exit 1
fi

DATALIST=$1
OUTPUT_ROOT="cleaning_grid_$(date '+%b%d_%Y')"
RES=$2

[ -z ${RES} ] && RES=100
#[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z

mbgrid -A2 -E${RES}/${RES}/meters! -F1 -I ${DATALIST} -JUTM20N -R$(mb.getregion) -V -O ${OUTPUT_ROOT}
rm ${OUTPUT_ROOT}.grd.cmd

# For some bizarre reason, when mbgrid outputs a datalist of the files it
# processed, it prepends a "P:" at the beginning of the line; we need to remove
# this if we want to process this datalist and have grids reflect processed
# edits.
cat ${OUTPUT_ROOT}.mb-1 | sed 's/^P://' > tmp && mv tmp ${OUTPUT_ROOT}.mb-1
cat ${OUTPUT_ROOT}.mb-1 | sed 's/^R://' > tmp && mv tmp ${OUTPUT_ROOT}.mb-1

exit 0

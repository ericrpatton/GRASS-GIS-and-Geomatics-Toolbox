############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        mb.reprocess_and_regrid_cleaning_datalist.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To reprocess a datalist after some edits have been done, then
# regrid the processed data and view the grid in mbgrdviz. Uses the current
# Grass geographic region as gridding bounds.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 February 25, 2021
# Last Modified: September 24, 2021
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

if [ "$#" -gt 2 -o "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raw_datalist_name [ resolution ] \n"
	exit 1
fi

DATALIST=$1
PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
OUTPUT_ROOT="Processed_$(basename ${PROCESSED_DATALIST} .mb-1)"
OUTPUT_GRID="${OUTPUT_ROOT}.grd"
RES=$2

[[ -z ${RES} ]] && RES=100
[[ ! -f "${PROCESSED_DATALIST}" ]] && mbdatalist -F-1 -I ${DATALIST} -Z

mbprocess -C8 -F-1 -I ${DATALIST} 
mbgrid -A2 -E${RES}/${RES}/meters! -F1 -I ${PROCESSED_DATALIST} -JEPSG:3395 -R$(mb.getregion) -V -O "${OUTPUT_ROOT}"

[[ "$?" -eq 0 ]] && echo -e "\nProduced output grid ${OUTPUT_ROOT}.grd.\n"
mbgrdviz -I ${OUTPUT_GRID}

# For some bizarre reason, when mbgrid outputs a datalist of the files it
# processed, it prepends a "P:" at the beginning of the line; we need to remove
# this if we want to process this datalist and have grids reflect processed
# edits.
#cat ${OUTPUT_ROOT}.mb-1 | sed 's/^P://' > tmp && mv tmp ${OUTPUT_ROOT}.mb-1
#cat ${OUTPUT_ROOT}.mb-1 | sed 's/^R://' > tmp && mv tmp ${OUTPUT_ROOT}.mb-1

rm ${OUTPUT_ROOT}.grd.cmd
rm ${OUTPUT_ROOT}.mb-1

exit 0

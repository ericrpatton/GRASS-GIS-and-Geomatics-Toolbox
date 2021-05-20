############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        mb.areaclean_tuning.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 February 26, 2021
# Last Modified: March 1, 2021
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

if [ "$#" -ne 4 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist_name binsize threshold nmin \n"
	exit 1
fi

DATALIST=$1
BINSIZE=$2
THRESHOLD=$3
NMIN=$4

PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
OUTPUT_ROOT="areaclean_grid_$(date '+%b%d_%Y')_bin${BINSIZE}_thres${THRESHOLD}_nmin${NMIN}"
OUTPUT_GRID=${OUTPUT_ROOT}.grd

RES=20
[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z

mbareaclean -F-1 -I ${DATALIST} -S${BINSIZE} -D${THRESHOLD}/${NMIN} -V
mbprocess -C8 -F-1 -I ${DATALIST} 
mbgrid -A2 -E${RES}/${RES}/meters! -F1 -I ${PROCESSED_DATALIST} -V -O "${OUTPUT_ROOT}"
	
echo -e "\nReprojecting with gdalwarp...\n"
gdalwarp -s_srs "EPSG:4326" -t_srs "$(g.proj -jf)" -of "GTiff" -tr ${RES} ${RES} -wm 30000000000 -r bilinear -multi -wo NUM_THREADS=ALL_CPUS ${OUTPUT_ROOT}.grd ${OUTPUT_ROOT}.tif
echo -e "\nImporting grid into Grass...\n"		
r.in.gdal input=${OUTPUT_ROOT}.tif mem=28000 output=${OUTPUT_ROOT} -o --o --v
r.colors map=${OUTPUT_ROOT} color=bof_unb --q

# Cleanup
[ "$?" -eq 0 ] && rm ${OUTPUT_ROOT}.tif && rm ${OUTPUT_ROOT}.grd.cmd && rm ${OUTPUT_ROOT}.mb-1

exit 0

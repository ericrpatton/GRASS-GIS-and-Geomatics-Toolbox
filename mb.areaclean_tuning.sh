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

if [ "$#" -lt 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist_name binsize [region] [threshold] [nmin] \n"
	exit 1
fi

DATALIST=$1

# Sets the size of the bins to be used in meters
BINSIZE=$2

# Set the processing region to that of the current GRASS computational region,
# if no region parameter was given on the command line.
[[ -z "$3" ]] && REGION=$(mb.getregion) || REGION=$3

#The threshold parameter turns  on  use of a standard deviation filter test for
#the soundings.  Soundings that differ from the mean depth by a value greater
#than threshold times the standard deviation will be considered "bad". So, if
#threshold = 2.0, then any sounding that is twice the standard deviation from
#the mean depth will be considered bad. The nmin parameter sets the minimum
#number of soundings required to use the standard deviation filter. The default
#values are threshold = 2.0 and #nmin = 10.

# Assign default values if non were given on the command line.
[[ -z "$4" ]] && THRESHOLD=2.0 || THRESHOLD=$4 
[[ -z "$5" ]] && NMIN=10 || NMIN=$5 


PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
OUTPUT_ROOT="areaclean_grid_$(date '+%b%d_%Y')_bin${BINSIZE}_thres${THRESHOLD}_nmin${NMIN}"
OUTPUT_GRID=${OUTPUT_ROOT}.grd

[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z

mbareaclean -F-1 -I ${DATALIST} -S${BINSIZE} -D${THRESHOLD}/${NMIN} -R${REGION} -V
mbprocess -C8 -F-1 -I ${DATALIST} 
mbgrid -A2 -E${BINSIZE}/${BINSIZE}/meters! -F1 -I ${PROCESSED_DATALIST} -R${REGION} -V -O "${OUTPUT_ROOT}"
#mbgrdviz -I ${OUTPUT_GRID}
	
# Use this section if you want to inspect the results in GRASS GIS.
echo -e "\nReprojecting with gdalwarp...\n"
gdalwarp -s_srs "EPSG:4326" -t_srs "$(g.proj -jf)" -of "GTiff" -tr ${BINSIZE} ${BINSIZE} -wm 30000000000 -r bilinear -multi -wo NUM_THREADS=ALL_CPUS ${OUTPUT_GRID} ${OUTPUT_ROOT}.tif
echo -e "\nImporting grid into Grass...\n"		
r.in.gdal input=${OUTPUT_ROOT}.tif mem=28000 output=${OUTPUT_ROOT} -o --o --v
r.colors map=${OUTPUT_ROOT} color=bof_unb --q

#Cleanup
[ "$?" -eq 0 ] && rm ${OUTPUT_ROOT}.tif && rm ${OUTPUT_ROOT}.grd.cmd && rm ${OUTPUT_ROOT}.mb-1

# This the non-Grass Cleanup routine
#[[ "$?" -eq 0 ]] && rm ${OUTPUT_ROOT}.grd.cmd && rm ${OUTPUT_ROOT}.mb-1

exit 0

#! /bin/bash
#
############################################################################
#
# MODULE:        mb.areaclean_tuning.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:      To process an MB-System datalist using user-provided mbareaclean
# parameters, or, if none are given by the user, sensible default values. The
# files in the datalist are then reprocessed, and imported into GRASS GIS. The
# GRASS GIS raster also has a colour table applied, and a coloured,
# shaded-relief raster is created from the input GRASS raster.
#
# COPYRIGHT:     (c) 2021-2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 February 26, 2021
# Last Modified: March 13, 2023
#
# NOTE: The output resolution is hardcoded for now.
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
	echo -e "\nusage: $SCRIPT datalist_name binsize [threshold (2.0)] [nmin (10)] \n"
	exit 1
fi

DATALIST=$1

# Sets the size of the bins to be used in meters used for statistical tests.
BINSIZE=$2

# Use the datalist extent to populate the REGION given with the -R flag.
REGION=$(mb.getinforegion) 

#The threshold parameter turns  on  use of a standard deviation filter test for
#the soundings.  Soundings that differ from the mean depth by a value greater
#than threshold times the standard deviation will be considered "bad". So, if
#threshold = 2.0, then any sounding that is twice the standard deviation from
#the mean depth will be considered bad. The nmin parameter sets the minimum
#number of soundings required to use the standard deviation filter. The default
#values are threshold = 2.0 and nmin = 10.

# Assign default values if none were given on the command line.
[[ -z "$3" ]] && THRESHOLD=2.0 || THRESHOLD=$3
[[ -z "$4" ]] && NMIN=10 || NMIN=$4 

PROCESSED_DATALIST="$(basename ${DATALIST} .mb-1)p.mb-1"
OUTPUT_RES=20
OUTPUT_ROOT="areaclean_grid_$(date '+%b%d_%Y')_bin${BINSIZE}_thres${THRESHOLD}_nmin${NMIN}_${OUTPUT_RES}m"
OUTPUT_GRID=${OUTPUT_ROOT}.grd

[ ! -f "${PROCESSED_DATALIST}" ] && mbdatalist -F-1 -I ${DATALIST} -Z

NPROC=$(nproc)

mbareaclean -F-1 -I ${DATALIST} -S${BINSIZE} -D${THRESHOLD}/${NMIN} -R${REGION} -B -V
mbprocess -C${NPROC} F-1 -I ${DATALIST} 
mbgrid -A2 -E${OUTPUT_RES}/${OUTPUT_RES}/meters! -F2 -I ${PROCESSED_DATALIST} -R${REGION} -M -V -O "${OUTPUT_ROOT}"
	
# Use this section if you want to inspect the results in GRASS GIS.
echo -e "\nReprojecting with gdalwarp...\n"
gdalwarp -s_srs "EPSG:4326" -t_srs "$(g.proj -jf | sed 's/+type=crs//')" -of "GTiff" -tr ${OUTPUT_RES} ${OUTPUT_RES} -wm 30000000000 -r bilinear -multi -wo NUM_THREADS=ALL_CPUS ${OUTPUT_GRID} ${OUTPUT_ROOT}.tif
echo -e "\nImporting grid into Grass...\n"		
r.in.gdal input=${OUTPUT_ROOT}.tif mem=28000 output=${OUTPUT_ROOT} -o --o --v
r.colors map=${OUTPUT_ROOT} color=bof_unb --q
r.csr input=${OUTPUT_ROOT}

exit 0

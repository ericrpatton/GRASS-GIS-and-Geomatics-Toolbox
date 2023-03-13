#! /bin/bash
#
############################################################################
#
# MODULE:        mb.kluge.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       A script to apply a series of lever arm corrections to an
# MB-System datalist, in order to attempt to fix artefacts in the data by trial
# and error.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  January 27, 2022
# Last Modified:  February 14, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

if [ "$#" -eq 0 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 [ VRUOFFSETX VRUOFFSETY VRUOFFSETZ SONAROFFSETX SONAROFFSETY | SONAROFFSETZ ] [ region [W/E/S/N]] [ resolution ]\n"
	exit 0
fi

INPUT=$1
LEVER_CORRECTION=$2

# Source make_filenames.sh, a script which handles all the filename wrangling
[[ -f /home/epatton/coderepo/make_filenames.sh ]] && set -- $INPUT && . /home/epatton/coderepo/make_filenames.sh

# Set the processing region to that of the input datalist region,
# if no region parameter was given on the command line.
[[ -z "$3" ]] && REGION=$(mb.getinforegion) || REGION=$3

# Assign default binsize values if none were given on the command line.
[[ -z "$4" ]] && BINSIZE=20 || BINSIZE=$4


# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

# Iterate theough a sequence of possible lever arm corrections, creating a grid
# for each to be visually inspected in GRASS GIS for improvements (if any).

for KLUGE in $(seq -2.0 0.1 2.0) ; do

	echo -e "\nApplying $LEVER_CORRECTION value ${KLUGE}...\n"
	sleep 1.25

	mbset -F-1 -I ${INPUT} -PLEVERMODE:1 -P"${LEVER_CORRECTION}:${KLUGE}"
	echo ""
	mbprocess -F-1 -I ${INPUT} -C8  
	echo ""
	
	MBGRID_OUT="${OUTPUT}_${LEVER_CORRECTION}_${KLUGE}"
	mbgrid -A2 -E${BINSIZE}/${BINSIZE}/meters! -F1 -I ${OUTPUT_PROC_MB1} -R${REGION} -V -O ${MBGRID_OUT}

	# Now reproject the grid and import into GRASS
	echo -e "\nReprojecting with gdalwarp...\n"
	
	TIFF_OUT=$(basename ${MBGRID_OUT} .grd).tif

	gdalwarp -s_srs "EPSG:4326" -t_srs $(g.proj -jf | sed 's/+type=crs//') -of "GTiff" -tr ${BINSIZE} ${BINSIZE} -wm 30000000000 -r bilinear -multi -wo NUM_THREADS=ALL_CPUS "${MBGRID_OUT}.grd" ${TIFF_OUT}
	echo -e "\nImporting grid into Grass...\n"		
	r.in.gdal input=${TIFF_OUT} mem=28000 output="${OUTPUT}_${LEVER_CORRECTION}_${KLUGE}" -o --o --v
	echo "" ; sleep 0.5
	r.colors map="${OUTPUT}_${LEVER_CORRECTION}_${KLUGE}"  color=bof_unb --q
	r.csr input="${OUTPUT}_${LEVER_CORRECTION}_${KLUGE}"
	
	#Cleanup
	[ "$?" -eq 0 ] && rm ${TIFF_OUT} && rm ${MBGRID_OUT}.grd.cmd && rm ${MBGRID_OUT}.grd && rm ${MBGRID_OUT}.mb-1

done

exit 0

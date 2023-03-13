############################################################################
#! /bin/bash
#
# MODULE:        import_grd.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       A script to import an MB-System-generated grid into GRASS GIS
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  February 18, 2022
# Last Modified:  February 18, 2022
#
#############################################################################

SCRIPT=$(basename $0)

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT gridname resolution\n"
	exit 0
fi

INPUT=$1
RES=$2

# Source make_filenames.sh, a script which handles all the filename wrangling
[[ -f /home/epatton/coderepo/make_filenames.sh ]] && set -- $INPUT && . /home/epatton/coderepo/make_filenames.sh

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

#echo "$INPUT"
#echo "$OUTPUT"

gdalwarp -overwrite -s_srs "EPSG:4326" -t_srs $(g.proj -jf | sed 's/+type=crs//') -of "GTiff" -tr ${RES} ${RES} -wm 25000000000 -r bilinear -multi -wo NUM_THREADS=MAX_CPUS ${INPUT} ${OUTPUT_TIFF}
echo -e "\nImporting grid into Grass...\n"		
r.in.gdal input=${OUTPUT_TIFF} mem=28000 output=${OUTPUT} -o --o --v
	
r.colors map=${OUTPUT} color=ryb --q
sleep ${PAUSE} ; r.optimize ${OUTPUT}
r.csr input=${OUTPUT}

exit 0


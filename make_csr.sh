#! /bin/bash 
#
############################################################################
#
# MODULE:        make_csr.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at Canada dot ca>
# 
# PURPOSE:       To create coloured, shaded-relief geotiffs from input GTM
#			     grids using the GDAL utlity gdaldem.
# 
# COPYRIGHT:    (c) 2006-2018 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: March 30, 2017
#	by Author
############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT gridname colourfile_name \n"
	exit 1
fi

GRID=$1
COLOUR=$2
BASENAME=`echo $GRID | cut -d. -f1`					       
SUFFIX="`echo $GRID | cut -d. -f2`"
TIFF_OUTPUT="$BASENAME.tif"


#if [ "$SUFFIX" != "tif" ] ; then
#	gdal_translate -of GTiff $GRID $TIFF_OUTPUT
#fi

INPUT=$TIFF_OUTPUT 
COLOUR_OUT="`basename $INPUT .tif`_colour.tif"
SHADE_OUT="`basename $INPUT .tif`_shade.tif"
CSR_OUT="`basename $INPUT .tif`_csr.tif"
GAMMA_OUT="`basename $CSR_OUT .tif`_gamma.tif"
GAMMA_CORR_OUT="`basename $GAMMA_OUT .tif`_corr.tif"
FINAL_OUT="`basename $CSR_OUT .tif`_final.tif"

gdaldem color-relief  ${INPUT} ${COLOUR} ${COLOUR_OUT}
gdaldem hillshade ${INPUT} ${SHADE_OUT} -z 5 -s 111120
hsv_merge.py ${COLOUR_OUT} ${SHADE_OUT} ${CSR_OUT} 

#convert -gamma .5 ${SHADE_OUT} ${GAMMA_OUT} 
#convert ${COLOUR_OUT} ${GAMMA_OUT} -compose Overlay -composite ${GAMMA_CORR_OUT}
#
#listgeo $INPUT > meta.txt
#geotifcp -g meta.txt ${GAMMA_CORR_OUT} ${FINAL_OUT}

exit 0

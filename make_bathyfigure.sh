#!/bin/bash
#
############################################################################
#
# MODULE:        make_bathyfigure.sh
#
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <eric dot patton at canada dot ca>
# 
# PURPOSE:       To export a bathymetry map from
#				 GRASS GIS and create a one-page GMT plot of the map, with
#				 accompanying graticules and color
#				 bars.
#		 		 
# COPYRIGHT:    (c) 2019 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: November 22, 2019
#	by Author
#############################################################################	

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathy_filename\n"
	exit 1
fi

# Define bathymetry map filenames
INPUT="$1"
GRID="${INPUT}.tif"
LL_GRID="$(basename $GRID .tif)_LL.tif"
SHADE="`basename $LL_GRID .tif`_shade.grd"
PROJ="U20/5.5i"
COLOR="$(basename $LL_GRID .tif).cpt"

#Export the GRASS raster to TIFF format
g.region rast=${INPUT}

if [ ! -f ${GRID} ] ; then
	#r.out.gdal in=${INPUT} out=${GRID} format=GTiff nodata=-9999 --v --o
	r.out.gdal in=${INPUT} out=${GRID} format=GTiff 
fi

echo ""

if [ ! -f ${LL_GRID} ] ; then
	gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -multi -wo NUM_THREADS=ALL_CPUS -wm 2500 -of "GTiff" ${GRID} ${LL_GRID}
fi

echo ""

# Create a color file for the incoming grid. Default is 'turbo'
if [ ! -f ${COLOR} ] ; then
	grd2cpt ${LL_GRID} -N -Z -V > ${COLOR}
	#grd2cpt ${LL_GRID} -N -Z -V > ${COLOR}

fi 

# Extract the maximum west/east/south/north coordintaes from grid
REGION=$(get_grid_wesn.sh ${LL_GRID})

#Make shaded-relief grid
if [ ! -f ${SHADE} ] ; then
	gmt grdgradient ${LL_GRID} -Ne0.6 -G${SHADE} -V -E125/30
fi

echo ""

# Now begin the plot
gmt begin  
gmt figure map pdf A+n

gmt grdimage -V ${LL_GRID} -C${COLORS} -I${SHADE} -J${PROJ} -R${REGION} -BWSen+t"$LL_GRID" -U+o0/-0.5i --PS_MEDIA=a4 -X1i -Y1i

gmt coast -Df -Gtan -Wthinnest -Bfa2mf1mg2m   

# MAP A Colourbar Placements:
# Upper-Right
#gmt colorbar -Dx2.75i/1.5i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"
# Bottom-Right
gmt colorbar -Dn0.92/0.85+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)" 
# Upper-Left
#gmt colorbar -Dx0.3i/1.5i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"
# Bottom-Left
#gmt colorbar -Dx0.3i/0.2i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"

gmt end show

exit 0

#!/bin/bash
#
############################################################################
#
# MODULE:        compare_bathy_and_bcksct.sh
#
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <eric dot patton at canada dot ca>
# 
# PURPOSE:       To export a pair of bathymetry and backscatter maps from
#				 GRASS GIS and create a one-page GMT plot of each map as
#				 indivdual figures, with accompanying graticules and color
#				 bars.
#		 		 
# COPYRIGHT:    (c) 2019 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: November 21, 2019
#	by Author
#############################################################################	

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 2 ] ; then
	echo -e "\nusage: $SCRIPT bathy_filename bcksct_filename\n"
	exit 1
fi

PROJ="U20/3i"

# Define bathymetry map filenames
MAP_A_INPUT="$1"
MAP_A_GRID="${MAP_A_INPUT}.tif"
MAP_A_LL_GRID="$(basename $MAP_A_GRID .tif)_LL.tif"
MAP_A_SHADE="$(basename $MAP_A_LL_GRID .tif)_shade.grd"
MAP_A_COLOR="$(basename $MAP_A_LL_GRID .tif).cpt"

# Define backscatter map filenames
MAP_B_INPUT="$2"
MAP_B_GRID="${MAP_B_INPUT}.tif"
MAP_B_LL_GRID="$(basename $MAP_B_GRID .tif)_LL.tif"
MAP_B_COLOR="$(basename $MAP_B_LL_GRID .tif).cpt"

# MAP A (BATHYMETRY)
#-------------------

if [ ! -f ${MAP_A_GRID} ] ; then
	g.region rast=${MAP_A_INPUT}
	r.out.gdal in=${MAP_A_INPUT} out=${MAP_A_GRID} format=GTiff nodata=-9999 --v --o
fi

echo ""

if [ ! -f ${MAP_A_LL_GRID} ] ; then
	gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -multi -wo NUM_THREADS=ALL_CPUS -wm 2500 -of "GTiff" ${MAP_A_GRID} ${MAP_A_LL_GRID}
fi

echo ""

# Create a color file for the incoming grid. Default is 'turbo'
if [ ! -f ${MAP_A_COLOR} ] ; then
	grd2cpt ${MAP_A_LL_GRID} -N -Z -V > ${MAP_A_COLOR}
fi 

#Make shaded-relief grid
if [ ! -f ${MAP_A_SHADE} ] ; then
	gmt grdgradient ${MAP_A_LL_GRID} -Ne0.6 -G${MAP_A_SHADE} -V -E35/30
fi

echo ""

# Extract the maximum west/east/south/north coordintaes from input bathymetry
# grid. 

A_REGION=$(get_grid_wesn.sh ${MAP_A_LL_GRID})

# MAP B (BACKSCATTER)
# -------------------

if [ ! -f ${MAP_B_GRID} ] ; then
	g.region rast=${MAP_B_INPUT}
	r.out.gdal in=${MAP_B_INPUT} out=${MAP_B_GRID} format=GTiff nodata=-9999 --v --o
fi

echo ""

if [ ! -f ${MAP_B_LL_GRID} ] ; then
	gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -multi -wo NUM_THREADS=ALL_CPUS -wm 2500 -of "GTiff" ${MAP_B_GRID} ${MAP_B_LL_GRID}
fi

echo ""

# Create a color file for the incoming grid. Default is 'turbo'
if [ ! -f ${MAP_B_COLOR} ] ; then
	grd2cpt ${MAP_B_LL_GRID} -Cgray -I -N -Z -V > ${MAP_B_COLOR}
fi 

# Extract the maximum west/east/south/north coordintaes from input backscatter
# grid. 
B_REGION=$(get_grid_wesn.sh ${MAP_B_LL_GRID})
echo ""

# Now plot both maps with their own graticules and colour bars
# The 'A+n' option is a command sent to psconvert to remove the tight bounding
# box cropping that takes place. Remove this flag to crop the output.
gmt begin map png

gmt grdimage ${MAP_A_LL_GRID} -C${MAP_A_COLOR} -I${MAP_A_SHADE} -J${PROJ} -R${A_REGION} -BWSen+t"$MAP_A_INPUT" 

gmt coast -Df -Gtan -Wthinnest -Bfa5mg5m  

# MAP A Colourbar Placement:
#gmt colorbar -Dn0.09/0.50+w3c/0.35c+malu -C${MAP_A_COLOR} -Bx10 -By+L"(m)"

gmt grdimage ${MAP_B_LL_GRID} -C${MAP_B_COLOR} -J${PROJ} -R${B_REGION} -BWSen+t"$MAP_B_INPUT" -X4i

gmt coast -Df -Gtan -Wthinnest -Ba5mg5m 

# MAP B Colourbar Placement:
#gmt colorbar -Dn0.09/0.10+w3c/0.35c+malu -C${MAP_B_COLOR} -Bx10 -By+L"(dB)"

gmt end show

exit 0

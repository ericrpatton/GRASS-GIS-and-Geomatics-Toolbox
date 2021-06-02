#!/bin/bash 
# 
##############################################################################
#
# MODULE:        make_openfile.sh
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
# Last Modified: May 29, 2021
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
INPUT_GRID="${INPUT}.tif"

SHADE="${INPUT}_shade"
RED="${INPUT}.r"
GREEN="${INPUT}.g"
BLUE="${INPUT}.b"
COLOR="${INPUT}.cpt"

RED_TIFF="${RED}.tif"
GREEN_TIFF="${GREEN}.tif"
BLUE_TIFF="${BLUE}.tif"

LL_RED_GRID="$(basename $RED_TIFF .tif)_LL.tif"
LL_GREEN_GRID="$(basename $GREEN_TIFF .tif)_LL.tif" 
LL_BLUE_GRID="$(basename $BLUE_TIFF .tif)_LL.tif"

PROJ="m-64/44.25/1:75000"

g.region rast=${INPUT}

# Check for a color file for the incoming grid. If one doesn't exist, first check for
# a tiff of the $INPUT, and create it if needed; then make a colortable from
# this tiff.

if [[ ! -f ${COLOR} ]] ; then
	if [[ ! -f ${INPUT_GRID} ]] ; then 
		r.out.demgeotiff ${INPUT}
	fi
	
	grd2cpt ${INPUT_GRID} -Chaxby -N -Z -V > ${COLOR} 
fi 

# Create the R/G/B maps if they do not yet exist
if [[ ! -f ${RED_TIFF} || ! -f ${GREEN_TIFF} || ! -f ${BLUE_TIFF} ]] ; then
	r.his hue=${INPUT} intensity=${SHADE} red=${INPUT}.r green=${INPUT}.g blue=${INPUT}.b --v --o 
	for MAP in ${RED} ${GREEN} ${BLUE} ; do
		r.out.demgeotiff ${MAP}
	done
fi

# Create the Lat/Long version of the R/G/B maps if they do not yet exist
if [[ ! -f ${LL_RED_GRID} || ! -f ${LL_GREEN_GRID} || ! -f ${LL_BLUE_GRID} ]] ; then
	for MAP in ${RED_TIFF} ${GREEN_TIFF} ${BLUE_TIFF} ; do
		gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -multi -wo NUM_THREADS=ALL_CPUS -wm 30000000000 -of "GTiff" ${MAP} "$(basename $MAP .tif)_LL.tif"
	done
fi

echo ""

# Extract the maximum west/east/south/north coordinates from Lat/Long grid
REGION=$(get_grid_wesn.sh ${LL_RED_GRID})

echo ""
# Now begin the plot
gmt begin  
gmt figure map pdf A+n

gmt grdimage -V ${LL_RED_GRID} ${LL_GREEN_GRID} ${LL_BLUE_GRID}  -C${COLOR} -J${PROJ} -R${REGION} -BWSen+t"Open File XXXX: Multibeam Bathymetry of Southwestern Nova Scotia" -U+o0/-0.5i -X3.5i -Y5i

gmt coast -Df -Gtan -Wthinnest -Bxa10mf5mg10m -Bya5mg5m  
#gmt coast -Df -Gtan -Wthinnest -Bxa10mf5m -Bya5m  

# Plot a 1x1 inch graticule to aid in text and decoration placement
#gmt plot vert_plotlines.txt -R0/46.8/0/33.1 -JX46.8i -N -Am -Wthinnest -V
#gmt plot horizontal_plotlines.txt -R0/46.8/0/33.1 -JX46.8i -N -Ap -Wthinnest -V
#gmt text horiz_plotline_labels.txt -N -D-0.5i/0 -F+a0+f20p,1,firebrick+jCM -V
#gmt text vert_plotline_labels.txt -N -D0/0.5i -F+a0+f20p,1,firebrick+jCM -V

gmt text lorem.txt -R0/46.8/0/33.1 -JX46.8i -F+a0+f12p,Helvetica+jRT -C0.25 -Wthick -M -N -V 
# MAP A Colourbar Placements:
# Upper-Right
#gmt colorbar -Dx2.75i/1.5i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"
# Bottom-Right
gmt colorbar -F+c2p/3p -Dx41i/19i+w10c/1.5c+malu  -C${COLOR} -Bx15 -By+L"(m)" 
# Upper-Left
#gmt colorbar -Dx0.3i/1.5i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"
# Bottom-Left
#gmt colorbar -Dx0.3i/0.2i+w3c/0.35c+malu -C${COLOR} -Bx10 -By+L"(m)"

gmt end show

exit 0

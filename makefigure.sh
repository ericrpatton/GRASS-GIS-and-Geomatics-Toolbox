#!/bin/bash
#
#
##############################################################################


if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT raster_name \n"
	exit 1
fi

RASTER=$1
GRID="${RASTER}.grd"
SHADE="${RASTER}_shade.grd"
PROJ="u20W"
SIZE="7.48i"

#Export the GRASS raster to GMT grid format
#r.out.bin --v -h input=${RASTER} output=${GRID}
r.out.gdal --v input=${RASTER} output=${GRID} format=GMT
echo ""

#Set the colors to the ones we like
r.colors map=${RASTER} color=bof_unb
echo ""

# Export the color table to GMT cpt format
r.out.cpt input=${RASTER} output=colors
COLORS="colors.cpt"

# Export the bounds of the UTM grid into a text file for parsing
grdinfo ${GRID} --D_FORMAT=%.10g -C > tmp.txt

#Make shaded-relief grid
grdgradient -V ${GRID}  -Nt1 -G${SHADE} -V -E35/35/=/0.7/0.5
echo ""

# Calculate the maximum Long-Lat boundaries of the UTM grid file for
# populating -R region flags

LL=`cut -f2,4 tmp.txt | mapproject -J${PROJ}/1:1 -F -C -I --OUTPUT_DEGREE_FORMAT=-D | awk '{printf "%s/%s\n", $1, $2}'`
UR=`cut -f3,5 tmp.txt | mapproject -J${PROJ}/1:1 -F -C -I --OUTPUT_DEGREE_FORMAT=-D | awk '{printf "%s/%s\n", $1, $2}'`

grdimage -V ${GRID} -C${COLORS} -I${SHADE} -JX${SIZE}/0 -K > map.ps 
echo ""

psbasemap -V -R${LL}/${UR}r -JU10W/$SIZE -O -K -B4m -Lx15/3/70:20N/10+l >> map.ps 
echo ""

psscale -V -D15/14/5/0.80 -A -B50/:\(m\): -C${COLORS} -O >> map.ps
echo ""

# -Te for EPS output
ps2raster -V -Tef map.ps > map.eps

exit 0

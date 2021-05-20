#! /bin/bash
#
# Shellscript to create Postscript plot of data in grd file
# Created by macro mbm_xyplot
#
# This shellscript created by following command line:
# mbm_xyplot -Inadir.dat -Onadir
#
# Define shell variables used in this script:
INPUT=$1

PS_FILE="graph.ps"
CPT_FILE= 
MAP_PROJECTION=x
MAP_SCALE="1.3979062470877/0.270761522668625"
MAP_REGION="0/6.4382/-476.6585/-455.4221"
X_OFFSET=1
Y_OFFSET=1.5
#
/bin/rm gmt.conf

# Set temporary GMT defaults
echo "Setting temporary GMT defaults..."
gmt gmtset PROJ_LENGTH_UNIT inch
gmt gmtset PS_MEDIA archA
gmt gmtset FONT_ANNOT_PRIMARY 8,Helvetica,black
gmt gmtset FONT_ANNOT_SECONDARY 8,Helvetica,black
gmt gmtset FONT_LABEL 8,Helvetica,black
gmt gmtset FONT_TITLE 10,Helvetica,black
gmt gmtset PS_PAGE_ORIENTATION LANDSCAPE
gmt gmtset COLOR_BACKGROUND black
gmt gmtset COLOR_FOREGROUND white
gmt gmtset COLOR_NAN white
gmt gmtset FORMAT_GEO_MAP ddd
#
# Make xy data plot
echo "Running gmt psxy..."
gmt psxy $INPUT \
	-J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-X$X_OFFSET -Y$Y_OFFSET -K -V > $PS_FILE
#
# Make basemap
echo "Running gmt psbasemap..."
gmt psbasemap -J$MAP_PROJECTION$MAP_SCALE \
	-R$MAP_REGION \
	-Bx0.5+l" " -By2+l" " -B+t"Data File $INPUT" \
	-O -V >> $PS_FILE
#
# Delete surplus files
echo "Deleting surplus files..."
/bin/rm -f gmt.conf
/bin/rm -f $CPT_FILE
#
#
# All done!
echo "All done!"

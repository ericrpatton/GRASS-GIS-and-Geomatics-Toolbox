#!/bin/bash
#
# dailynav.sh
#
# A wrapper script to combine several daily navigation processing scripts to
# generate the data products typically required on a geophysical survey.
#
# Date Created: June 10, 2016
#
#############################################################################

if  [ -z $GISBASE ] ; then
 echo "You must be in GRASS GIS to run this program."
 exit 1
fi

# Dynamically assign input and output filename based on the input e-file.

EFILE=$1													   # Huds179a.16E
BASENAME=`echo $EFILE | cut -d. -f1`					       # Huds179a
A_SUFFIX="`echo $EFILE | cut -d. -f2 | sed 's/E/a/'`"		   # 16a
AFILE="${BASENAME}_1s.${A_SUFFIX}"							   # Huds179a_1s.16a
MIN_AFILE="${BASENAME}_60s.${A_SUFFIX}"						   # Huds179a_60s.16a
GRASS_POINTS_NAME="`basename $MIN_AFILE .${A_SUFFIX}`_points"  # Huds179a_60s_points
GRASS_LINES_NAME="`basename $GRASS_POINTS_NAME _points`_lines" # Huds179a_60s_lines
GRASS_POINTS_NAME_LL="${GRASS_POINTS_NAME}_LL.shp"			   # Huds179a_60s_points_LL.shp
GRASS_LINES_NAME_LL="${GRASS_LINES_NAME}_LL.shp"			   # Huds179a_60s_lines_LL.shp
GRASS_1S_POINTS_NAME="`basename $AFILE .${A_SUFFIX}`_points"   # Huds179a_1s_points
GRASS_1S_LINES_NAME="`basename $AFILE .${A_SUFFIX}`_lines"     # Huds179a_1s_lines
GMT_NAME=${GRASS_POINTS_NAME}.gmt							   # Huds179a_60s_points.gmt
GMT_LL_NAME="`basename $GMT_NAME .gmt`_LL.gmt"				   # Huds179a_60s_points_LL.gmt

# Define cleanup procedures
exit_cleanup()
{
	if [ -f ${GMT_NAME} ] ; then rm -v ${GMT_NAME} ; fi
	if [ -f "${GRASS_POINTS_NAME}.shp" ] ; then rm -v ${GRASS_POINTS_NAME}.* ; fi
	if [ -f "${GRASS_LINES_NAME}.shp" ] ; then rm -v ${GRASS_LINES_NAME}.* ; fi
	if [ -f "${GRASS_1S_POINTS_NAME}.shp" ] ; then rm -v ${GRASS_1S_POINTS_NAME}.* ; fi
	if [ -f "${GRASS_1S_LINES_NAME}.shp" ] ; then rm -v ${GRASS_1S_LINES_NAME}.* ; fi
	if [ -f "${GRASS_POINTS_NAME}_LL.shp" ] ; then rm -v ${GRASS_POINTS_NAME}_LL.* ; fi
	if [ -f "${GRASS_LINES_NAME}_LL.shp" ] ; then rm -v ${GRASS_LINES_NAME}_LL.* ; fi
	if [ -f "${GMT_LL_NAME}" ] ; then rm -v ${GMT_LL_NAME} ; fi
	echo ""
}

normal_cleanup()
{
	rm -v ${GRASS_POINTS_NAME}.*
	rm -v ${GRASS_LINES_NAME}.*
	rm -v ${GRASS_1S_POINTS_NAME}.*
	rm -v ${GRASS_1S_LINES_NAME}.*
	rm -v ${GMT_NAME}
}

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n"
	exit_cleanup
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks (signal list: trap -l):
trap "exitprocedure" 2 3 15

# Run the scripts!
echo -e "\n\n<<===== Processing navigation file $EFILE...please standby. =====>>\n" ;

nmea2a.sh ${EFILE}
v.in.afile ${AFILE}
afile_decimate.sh ${AFILE}
v.in.afile ${MIN_AFILE}
#v.out.ogr input=${GRASS_POINTS_NAME} format="OGR_GMT" output=${GMT_NAME} --v --o
v.out.ogr input=${GRASS_POINTS_NAME} format="ESRI_Shapefile" output=${GRASS_POINTS_NAME}.shp -e --o --v
v.out.ogr input=${GRASS_LINES_NAME}  format="ESRI_Shapefile" output=${GRASS_LINES_NAME}.shp -e --o --v
v.out.ogr input=${GRASS_1S_POINTS_NAME} format="ESRI_Shapefile" output=${GRASS_1S_POINTS_NAME}.shp -e --o --v
#v.out.ogr input=${GRASS_1S_LINES_NAME} format="ESRI_Shapefile" output=${GRASS_1S_LINES_NAME}.shp -e --o --v
#ogr2ogr -t_srs "EPSG:4326" -overwrite -f "OGR_GMT" ${GMT_LL_NAME} ${GMT_NAME}
ogr2ogr -t_srs "EPSG:4326" -overwrite -f "ESRI Shapefile" ${GRASS_POINTS_NAME_LL} ${GRASS_POINTS_NAME}.shp
ogr2ogr -t_srs "EPSG:4326" -overwrite -f "ESRI Shapefile" ${GRASS_LINES_NAME_LL} ${GRASS_LINES_NAME}.shp
ogr2ogr -t_srs "EPSG:4326" -overwrite -f "ESRI Shapefile" ${GRASS_1S_POINTS_NAME}_LL.shp ${GRASS_1S_POINTS_NAME}.shp
#ogr2ogr -t_srs "EPSG:4326" -overwrite -f "ESRI Shapefile" ${GRASS_1S_LINES_NAME}_LL.shp ${GRASS_1S_LINES_NAME}.shp

#make_navplot.sh ${GMT_LL_NAME}

# Cleanup
normal_cleanup

exit 0

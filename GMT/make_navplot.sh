#!/bin/bash
#
#	makenavplot.sh
#
#	A script for generating GMT plots of A-File-type navigation
#
#   Last modified: August 1, 2020
#
#	Note: The navigation and labels files are expected to be in GMT format;
#	use v.out.ogr to generate these. A labels file can be the same file as the
#	nav; all that is being used for labels are the timestamps from the nav
#	file. The script attempts to detect the navigation file type by checking
#	the first underscore-delimited word that occurs in the filename. Accepted
#	types are All, Seismic, Huntec, and Knudsen. If the file name matches
#	none of these, the default Regulus a-file type is assumed. 
#   
#   The script also attempts to dynamically calculate several cartographical
#   elements based on the size of the input data, and the inferred instrument
#   type.
#
#############################################################################

SCRIPT=$(basename $0)

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT navfilename region (W/E/S/N) \n"
	exit 1
fi

# Using the input navigation file as the labels to simplify things.
NAV=$1
REGION=$2
LABELS=$1

echo -e "\n\n========== Generating map for $NAV ==========\n"
NAV_BASENAME="`echo $NAV | cut -d. -f1`"
NAV_SUFFIX=".`echo $NAV | cut -d. -f2`"

# Create the output postscript filename template. If $AREA is null, only a
# '.ps' gets appended to the output filename. 
OUTPUT_BASE="`basename $NAV $NAV_SUFFIX`"
OUTPUT="${OUTPUT_BASE}${AREA}.ps"

# Define cleanup procedures
cleanup()
{
	if [ -f ${OUTPUT} ] ; then
		rm -v ${OUTPUT}
	fi

	unset REGION
}

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n"
	cleanup
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks (signal list: trap -l):
trap "exitprocedure" 2 3 15

CRUISE="Hudson 2017016"

# If a region was passed as a parameter on the command line, use it.
case $2 in

	WEST) REGION="-65/-63/41.25/43"
		  AREA_TITLE="Western Region"
		  AREA="_West"

		;;
	
	CENTRAL) REGION="-63/-61/41.5/43"
			 AREA_TITLE="Central Region"
			 AREA="_Central"
		;;

	EAST) REGION="-61/-59/42.5/44"
		  AREA_TITLE="Eastern Region"
		  AREA="_East"
		;;

	*) :
		;;

esac


if [ -z ${REGION} ] ; then

	#  Dynamically calculate the region to be used for the GMT graticule,
	#  since none was provided as a parameter to the script.  
	
	# Extract the region bounds of the nav file
	echo -e "\nNo region extents provided; extracting region extents from input nav file..."
	WEST=`gmtinfo $NAV | awk '{print $5}' | cut -d'/' -f1 | sed 's/<//'`
	EAST=`gmtinfo $NAV | awk '{print $5}' | cut -d'/' -f2 | sed 's/>//'`
	SOUTH=`gmtinfo $NAV | awk '{print $6}' | cut -d'/' -f1 | sed 's/<//'`
	NORTH=`gmtinfo $NAV | awk '{print $6}' | cut -d'/' -f2 | sed 's/>//'`
	echo -e "\nThe calculated region is $WEST/$EAST/$SOUTH/$NORTH"
	
	# If the SW-NE diagonal extent of the data is less than some default value,
	# use a zoomed-in graticule where the SW-NE bounds are extended from the
	# centre point of the data by an amount equal to 1/2 the zoom factor in
	# both the NE and SW direction, at a 45 degree angle.
	MAP_BREADTH=`echo "$SOUTH $WEST $NORTH $EAST" | geod -I -f "%.6f" +ellps=WGS84 +units=km | awk '{print $3}'`
	MAP_BREADTH_ROUND=`echo $MAP_BREADTH | awk '{printf "%d\n", $1}'`
	HALF_BREADTH=`echo "$MAP_BREADTH / 2" | bc -l` 
	MAP_CENTRE_LAT=`echo "$SOUTH $WEST 45 $HALF_BREADTH" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $1}'`
	MAP_CENTRE_LONG=`echo "$SOUTH $WEST  45 $HALF_BREADTH" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $2}'`
	
	# Determine how much to pad the graticule region. The if test is in
	# kilometres.
	
	if [ $MAP_BREADTH_ROUND -lt 100 ] ; then
		
		# Zoomed map:
		MAPTYPE="zoomed"
		ZOOM_FACTOR=3
		X_ANNOT="11m"
		Y_ANNOT="5m"
		SCALECOORDS="n0.50/0.04"
	    ARROWCOORDS="n0.02/0.95"
	else
	
		# Regional map:
		MAPTYPE="regional"
		ZOOM_FACTOR=1.5
		X_ANNOT=2
		Y_ANNOT="1"
		SCALECOORDS="n0.50/0.04"
		ARROWCOORDS="n0.02/0.95"
	fi
	
	# Now calculate the new graticule bounds
	ZOOM_PADDING=`echo "(($MAP_BREADTH * $ZOOM_FACTOR) / 2)" | bc -l`
	UR_CORNER_LONG=`echo "$MAP_CENTRE_LAT $MAP_CENTRE_LONG 45 $ZOOM_PADDING" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $2}'`
	UR_CORNER_LAT=`echo "$MAP_CENTRE_LAT $MAP_CENTRE_LONG 45 $ZOOM_PADDING" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $1}'`
	LL_CORNER_LONG=`echo "$MAP_CENTRE_LAT $MAP_CENTRE_LONG -135 $ZOOM_PADDING" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $2}'`
	LL_CORNER_LAT=`echo "$MAP_CENTRE_LAT $MAP_CENTRE_LONG -135 $ZOOM_PADDING" | geod -f "%.6f" +ellps=WGS84 +units=km | awk '{print $1}'`

	# Assign the newly-calculated padded graticule bounds to the GMT REGION.
	REGION="${LL_CORNER_LONG}/${UR_CORNER_LONG}/${LL_CORNER_LAT}/${UR_CORNER_LAT}"

	# Dynamically calculate the scalebar width based on the map region width
	REGION_WIDTH=`echo ${LL_CORNER_LAT} ${LL_CORNER_LONG} ${UR_CORNER_LAT} ${UR_CORNER_LONG} | geod -I -f "%.6f" +ellps=WGS84 +units=kmi | awk '{print $3}'`
	REGION_WIDTH_INT=`echo $REGION_WIDTH | awk '{printf "%d\n", $1}'`
	
	if [ $REGION_WIDTH_INT -lt 10 ] ; then

		SCALE_LENGTH=`echo "($REGION_WIDTH /1.852) * 0.5" | bc -l | awk '{printf "%d\n", $1}'`

	else
		SCALE_LENGTH=`echo "($REGION_WIDTH / 1.852) * 0.5" | bc -l | awk '{printf "%d\n", $1}'`

	fi

    echo "Scale length is $SCALE_LENGTH."
    echo "Region width is $REGION_WIDTH."
	
else
	

	echo -e "\nUsing provided region extents:"
	echo "$REGION"
	SCALE_LENGTH=40
	X_ANNOT=1
	Y_ANNOT="30m"
	SCALECOORDS="n0.50/0.04"
	ARROWCOORDS="n0.02/0.95"

fi

# Detect what type of navigation file we are dealing with.
# NOTE: This script assumes the navigation instrument type is the first portion
# of the filename.
NAVTYPE="`echo $NAV | cut -d'_' -f1`"

# Dynamically assign cartography elements based on detected navigation type

case ${NAVTYPE} in

	Huntec)	 echo -e "\nUsing $MAPTYPE $NAVTYPE navigation carto elements...\n" 
			 LINECOLOUR="darkbrown"
			 LINE="`echo $NAV | awk -F'_' '{print $8}' | cut -d. -f1 | sed 's/Line//'`"
			 LINE_START="`echo $NAV | awk -F'_' '{print $3}'`"
			 LINE_END="`echo $NAV | awk -F'_' '{print $6}'`"
			
			 if [ ${LINE_START} -eq ${LINE_END} ] ; then
				 LINE_JD=${LINE_START}
			 else
				 LINE_JD="${LINE_START} to ${LINE_END}"
			 fi
			 
			 TITLE="${CRUISE} ${NAVTYPE} Line ${LINE}, JD${LINE_JD}"
	
			 ;;

	 Knudson) echo -e "\nUsing $MAPTYPE $NAVTYPE navigation carto elements...\n"
			  FREQUENCY="`echo $NAV | awk -F'_' '{print $2}'`"
			  
			  if [ ${FREQUENCY} = "12kHz" ] ; then

					LINECOLOUR="lightorange"
					LINE_START="`echo $NAV | awk -F'_' '{print $3}'`"
					LINE_END="`echo $NAV | awk -F'_' '{print $6}'`"
			  
			  else
				    FREQUENCY="3.5kHz"
					LINECOLOUR="darkorange"
					LINE_START="`echo $NAV | awk -F'_' '{print $4}'`"
					LINE_END="`echo $NAV | awk -F'_' '{print $7}'`"
				  
			  fi
			
			  if [ ${LINE_START} -eq ${LINE_END} ] ; then
			      LINE_JD=${LINE_START} else
			      LINE_JD="${LINE_START} to ${LINE_END}"
			  fi
			  

			  TITLE="${CRUISE} ${NAVTYPE} ${FREQUENCY} Trackline, JD${LINE_JD}"
	
			  ;;

     Airgun) echo -e "\nUsing $MAPTYPE $NAVTYPE navigation carto elements...\n"
			  LINECOLOUR="0.75p,seagreen1"
			  LINE="`echo $NAV | awk -F'_' '{print $9}' | sed 's/Line//'`"
			  LINE_START="`echo $NAV | awk -F'_' '{print $2}'`"
			  LINE_END="`echo $NAV | awk -F'_' '{print $4}'`"
			
			  if [ ${LINE_START} -eq ${LINE_END} ] ; then
			      LINE_JD=${LINE_START}
			  else
			      LINE_JD="${LINE_START} to ${LINE_END}"
			  fi
			  
			  TITLE="${CRUISE} ${NAVTYPE} Line ${LINE}, JD${LINE_JD}"
		
			  ;;

			  
	    All)  INSTRUMENT="`echo $NAV | cut -d'_' -f2`"
			  echo -e "\nUsing $MAPTYPE $INSTRUMENT carto elements...\n"
			  TITLE="${CRUISE} ${NAVTYPE} ${INSTRUMENT} Tracklines, ${AREA_TITLE}"

				  if [ ${INSTRUMENT} == "Airgun" ] ; then
					  LINECOLOUR="0.75p,black"
				 
				  elif [ ${INSTRUMENT} == "Huntec" ] ; then
					  LINECOLOUR="0.75p,black"
			      
				  elif [ ${INSTRUMENT} == "Knudson" ] ; then
					  LINECOLOUR="0.75p,black"

				  else 
					  LINECOLOUR="0.75p,black"	  
				  fi

			  ;;

	 *)		  echo -e "\nUsing default $MAPTYPE navigation carto elements...\n"
			  LINECOLOUR="0.75p,red"	  
			  JULIAN_DAY="`echo $NAV_BASENAME | awk '{print substr($1,5,3)}'`"
			  TITLE="${CRUISE} Navigation Trackline, JD${JULIAN_DAY}"
			  
			  ;;
esac

# For use with Mercator projection, i.e., '-JM'
WIDTH="15c"

BATHYIMAGE="GEBCO_2014_2D_68W_40N_50W_53N_GMT_ocean_CSR.tif"

# Lambert Conformal Conic projection (use -Jl to specify a scale):
#pscoast -JL${PROJ}/${WIDTH} -R${REGION} -Bxa4f2 -B+t"${TITLE}" -Bya4f2 -Df -Gtan -W -V -K > ${OUTPUT}

# Background Bathymetry; Mercator projection for nice rectangular graticule
# (use -Jm to specify a scale):
#TITLE="Hudson 2016011Phase2 Sampling Stations"
grdimage ${BATHYIMAGE} -JM${WIDTH} -R${REGION} -Bxa${X_ANNOT}f${X_ANNOT}g${X_ANNOT} -B+t"${TITLE}" -Bya${Y_ANNOT}f${Y_ANNOT}g${Y_ANNOT} --FONT_TITLE=13p -D -K -V > ${OUTPUT} 

pscoast -J -Bxa${X_ANNOT}f${X_ANNOT}g${X_ANNOT} -Bya${Y_ANNOT}f${Y_ANNOT}g${Y_ANNOT} -R -Df -Gtan -W -V -O -K -L${SCALECOORDS}+c42N+w${SCALE_LENGTH}n+ar+lNm+f+jBL -Td${ARROWCOORDS}+w0.6i+l+jTL --FONT_LABEL=7p --FONT_TITLE=7p,Helvetica-Bold, --MAP_LABEL_OFFSET=12p -t30 >> ${OUTPUT}

# Optional GMT timestamp code: (append to pscoast command above)-UBL/-3/-2

# Draw the navigation track; since no symbol code is given, (-S), GMT connects
# the dots to make a continuous line. The -gd paramter allow us to break the
# line at data gaps greater than the distance value given; append the units.

#STATIONS="Hudson_2016011_Stations_LL.gmt"

psxy ${NAV} -J -R -O -V -W${LINECOLOUR} -gd1k >> ${OUTPUT}
#psxy $STATIONS -J -R -O -V -Sc6p -Wthinner -Gwhite >> ${OUTPUT}
# Legend
#pslegend legend.txt -J -R -B -O -K -Dx0.90i/1i/3.2i/1i/BL -F+gwhite+i+p1p -V >> ${OUTPUT}

# Draw circles at each hour interval; this method will only work for point GMT
# files that have unique timestamp for each lat-long point pair.
#awk -F'|' '/^#/ {if (substr($2,4,2) == "00") {print $6, $5}}' ${NAV} | psxy -J -R -V -O -Sc4p -Gblue -W >>  ${OUTPUT}

# Draw horizontal tick marks at each half hour interval
#awk -F'|' '/^#/ {if (substr($2,4,2) == 30) {print $2, $3}}' ${NAV} | psxy -J -R -V -O -K -S-8p -Wthick >> ${OUTPUT}

# Render the timestamps; labels are offset by the -D flag. The angle of
# rotation for the label text is controlled by the fourth parameter in the awk
# print statement below.

#awk -F'|' '/^#/ {if (substr($2,4,2) == "00") print $1, $3, $7"-"$8}' ${LABELS} | pstext -J -R -O -D0.1 -F+a0+f5p,Helvetica-Bold,black+jBL >> ${OUTPUT}

# Make a pdf of the postscript output; -Tj for jpeg, -Tf for PDF, -Tg for png,
# -Te for eps.
psconvert ${OUTPUT} -Tj -V -P -A
psconvert ${OUTPUT} -Te -V -P -A

if [ -s ${OUTPUT} ] ; then
	echo -e "\nFinished! Produced output map ${OUTPUT}"
fi

exit 0

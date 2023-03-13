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

if  [[ -z "$GISBASE" ]] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT bathy_filename resolution\n"
	exit 0
fi

# Copy the standard gmt.conf file from the home directory if there is none in the
# current working directory.

if [[ ! -f "gmt.conf" ]] ; then cp ~/gmt.conf . ; fi

# Define bathymetry map filenames
INPUT=${1}
RES=${2}
GRID="${INPUT}.tif"
LL_GRID="$(basename $GRID .tif)_LL.tif"
SHADE="`basename $LL_GRID .tif`_shade.grd"
PROJ="M5.5i"
COLOR="$(basename $LL_GRID .tif).cpt"
PAUSE=2
# Set region to the extent of input raster
g.region rast=${INPUT} res=${RES}

if [[ ! -f ${GRID} ]] ; then r.out.gdal in=${INPUT} out=${GRID} format=GTiff nodata=-9999 ; fi

echo ""

if [[ ! -f ${LL_GRID} ]] ; then
	gdalwarp -t_srs "EPSG:4326" -overwrite -r cubic -srcnodata -9999 -dstnodata "NaN" -multi -wo NUM_THREADS=ALL_CPUS -wm 30000000000 -of "GTiff" ${GRID} ${LL_GRID}
fi

echo ""

# Create a color file for the incoming grid. Default is 'turbo'
if [[ ! -f ${COLOR} ]] ; then

	# The incoming raster's colorbar can be truncated by using the -L flag to
	# only include values within a certain range. A value of 'nan' ignores that
	# end of the spectrum.

	# Estimate a reasonable number of colorbar intervals based on the z-range of
	# the incoming raster.
	
	MIN=$(floor.sh $(list_range.sh ${INPUT} | grep min | cut -d'=' -f2))
	MAX=$(ceil.sh $(list_range.sh ${INPUT} | grep max | cut -d'=' -f2))

	echo "MIN is $MIN."
	echo -e "MAX is $MAX.\n"

	sleep ${PAUSE}

	MIN_ABS_VALUE=$(abs_value.sh ${MIN})
	MAX_ABS_VALUE=$(abs_value.sh ${MAX})

	echo "MIN_ABS_VALUE is $MIN_ABS_VALUE."
	echo -e "MAX_ABS_VALUE is $MAX_ABS_VALUE.\n"

	sleep ${PAUSE}
	# Round the deepest z-value down to the next 10s place for in order to have
	# a neat colorbar annontation range.

	MIN_MOD_10_REMAINDER=$(echo $MIN_ABS_VALUE | awk '{print $1 % 10}')

	if [[ $MIN_MOD_10_REMAINDER -ne 0 ]] ; then
		MIN_ADJUSTMENT=$((10 - $MIN_MOD_10_REMAINDER))
		MIN_ANNOT=$((($MIN_ABS_VALUE + $MIN_ADJUSTMENT) * (-1)))
		echo "New annotation minima adjusted to $MIN_ANNOT."	
		sleep ${PAUSE}
	else
		MIN_ANNOT=${MIN}
	fi

	# Similarly, round the shoalest z-value up to the next 10s place.

	MAX_MOD_10_REMAINDER=$(echo $MAX_ABS_VALUE | awk '{print $1 % 10}')

	if [[ $MAX_MOD_10_REMAINDER -ne 0 ]] ; then
		MAX_ANNOT=$((($MAX_ABS_VALUE - $MAX_MOD_10_REMAINDER) * (-1)))
		echo "New annotation maxima adjusted to $MAX_ANNOT."	
		sleep ${PAUSE}
	else 
		MAX_ANNOT=${MAX}
	
	fi

	echo "MIN_ANNOT is $MIN_ANNOT."
	echo -e "MAX_ANNOT is $MAX_ANNOT.\n"

	sleep ${PAUSE}

	ZRANGE=$(abs_value.sh $(($MAX - $MIN)))

	if [[ ${ZRANGE} -lt 100 ]] ; then
		COLOR_TICK=20

	elif [[ ${ZRANGE} -lt 500 ]] ; then
		COLOR_TICK=100

	elif [[ ${ZRANGE} -lt 1000 ]] ; then
		COLOR_TICK=250	
	
	else COLOR_TICK=1000

	fi

	echo -e "\nUsing a colorbar tick interval of $COLOR_TICK.\n"
	sleep ${PAUSE}

	# Note: -E sets a linear color table as opposed to the default of
	# histogram-equalized; -E and -T are mutually exclusive.

	gmt grd2cpt ${LL_GRID} -Chaxby -L${MIN_ANNOT}/${MAX_ANNOT} -T${MIN_ANNOT}/${MAX_ANNOT}/${COLOR_TICK} -N -V -Z > ${COLOR}
	#gmt grd2cpt ${LL_GRID} -Chaxby -N -L-6000/0 -V -Z > ${COLOR}

fi 

# Extract the maximum west/east/south/north coordintaes from grid
REGION=$(get_gmt_region.sh ${LL_GRID})

# Calculate reasonable grid tick intervals

# Parse the REGION string into its components
WEST=$(echo $REGION | cut -d'/' -f1)
EAST=$(echo $REGION | cut -d'/' -f2)
SOUTH=$(echo $REGION | cut -d'/' -f3)
NORTH=$(echo $REGION | cut -d'/' -f4)

WEST_EAST_DIFF=$(abs_value.sh $(echo "scale=6 ; $WEST - $EAST" | bc -l))
NORTH_SOUTH_DIFF=$(abs_value.sh $(echo "scale=6 ; $NORTH - $SOUTH" | bc -l))

echo -e "\nFigure spans $WEST_EAST_DIFF deg of longitude."
echo -e "Figure spans $NORTH_SOUTH_DIFF deg of latitude.\n"

sleep ${PAUSE}

# Calculate a reasonable west-east grid tick interval
# (Taken from the MB-System macro mbm_plot)

if (( $(echo "$WEST_EAST_DIFF < 0.00006944444445" | bc -l) )) ; then
   {
   WEST_EAST_TICK="0.075s"
   }

elif (( $(echo "$WEST_EAST_DIFF < 0.00013888888889" | bc -l) )) ; then
   {
   WEST_EAST_TICK="0.15s"
   }

elif (( $(echo "$WEST_EAST_DIFF < 0.0002777777" | bc -l) )) ; then
   {
   WEST_EAST_TICK="0.3s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0005555555" | bc -l) )) ; then
   {
   WEST_EAST_TICK="0.6s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0013888889" | bc -l) )) ; then
   {
   WEST_EAST_TICK="1.5s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0027777778" | bc -l) )) ; then
   {
   WEST_EAST_TICK="3s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0041666667" | bc -l) )) ; then
   {
   WEST_EAST_TICK="5s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0083333333" | bc -l) )) ; then
   {
   WEST_EAST_TICK="10s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0166667" | bc -l) )) ; then
   
   {
   WEST_EAST_TICK="20s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0333333" | bc -l) )) ; then
   {
   WEST_EAST_TICK="30s"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.0833333" | bc -l) )) ; then
   {
   WEST_EAST_TICK="1.5m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.1666667" | bc -l) )) ; then
   {
   WEST_EAST_TICK="3m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.25" | bc -l) )) ; then
   {
   WEST_EAST_TICK="5m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 0.5" | bc -l) )) ; then
   {
   WEST_EAST_TICK="10m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 1.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="20m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 2.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="30m"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 5.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="1.5"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 10.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="3"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 15.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="5"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 30.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="10"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 60.0" | bc -l) )) ; then
   {
   WEST_EAST_TICK="20"
   }
 
elif (( $(echo "$WEST_EAST_DIFF < 360.0)" | bc -l) )) ; then
   {
   WEST_EAST_TICK="30"
   }
fi

# Calculate north-south-grid tick interval
if (( $(echo "$NORTH_SOUTH_DIFF < 0.00006944444445" | bc -l) )) ; then

   {
   NORTH_SOUTH_TICK="0.075"
   }

elif (( $(echo "$NORTH_SOUTH_DIFF < 0.00013888888889" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="0.15"
   }

elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0002777777" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="0.3s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0005555555" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="0.6s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0013888889" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="1.5s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0027777778" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="3s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0041666667" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="5s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0083333333" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="10s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0166667" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="20s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0333333" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="30s"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.0833333" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="1.5m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.1666667" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="3m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.25" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="5m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 0.5" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="10m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 1.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="20m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 2.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="30m"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 5.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="1.5"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 10.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="3"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 15.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="5"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 30.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="10"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 60.0" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="20"
   }
 
elif (( $(echo "$NORTH_SOUTH_DIFF < 360.0)" | bc -l) )) ; then
   {
   NORTH_SOUTH_TICK="30"
   }
fi

#Make shaded-relief grid
if [[ ! -f ${SHADE} ]] ; then
	#gmt grdgradient ${LL_GRID} -Ne0.6+a1.5 -G${SHADE} -V -E125/60
	gmt grdgradient ${LL_GRID} -G${SHADE} -V -Es125/80
fi

echo ""

# Now begin the plot
gmt begin  
gmt figure ${INPUT} eps,png A E720

#gmt grdimage -V @earth_relief_01m -Cdevon -I+d 
gmt grdimage -V ${LL_GRID} -C${COLOR} -I${SHADE} -Q -J${PROJ} -R${REGION}  -Bx${WEST_EAST_TICK}g${WEST_EAST_TICK} -By${NORTH_SOUTH_TICK}g${NORTH_SOUTH_TICK}
gmt coast -Df -Gtan -Wthinnest -Bx${WEST_EAST_TICK}g${WEST_EAST_TICK} -By${NORTH_SOUTH_TICK}g${NORTH_SOUTH_TICK}

# MAP A Colourbar Placements:
# Upper-Right
#gmt colorbar -Dn0.95/0.70+w3c/0.35c+malu -C${COLOR} -By+L"(m)" -Bx${COLOR_TICK}

# Bottom-Right
gmt colorbar -Dn0.94/0.06+w3.5c/0.3c+malu -C${COLOR} -Bx${COLOR_TICK} -By+L"(m)" 

# Upper-Left
#gmt colorbar -D0.05/0.80+w3c/0.35c+malu -C${COLOR} -Bx${COLOR_TICK} -By+L"(m)"

# Bottom-Left
#gmt colorbar -Dn0.05/0.05+w3c/0.35c+malu -C${COLOR} -Bx${COLOR_TICK} -By+L"(m)"

gmt end

exit 0

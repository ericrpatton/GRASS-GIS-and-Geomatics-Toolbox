#! /bin/bash
#
############################################################################
#
# MODULE:        MODULENAME for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       Splits the current computational region into a user-provided
# number of equal-sized chucnks, and prints the bounds of each to the command
# line and to a file.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 30, 2021
# Last Modified: November 30, 2021
#
#############################################################################
#%Module
#% description: Fragments the current computational region into a specified number of smaller sections
#%END

#%flag
#% key: v
#% description: Set verbose mode
#%END

#%option
#% key: rows
#% type: integer
#% required: yes
#% description: Number of rows to divide into the raster
#%END

#%option
#% key: cols
#% type: integer
#% required: yes
#% description: Number of columns to divide into the raster
#%END

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

if [ "$1" != "@ARGS_PARSED@" ] ; then
     exec g.parser "$0" "$@"
fi

SCRIPT=$(basename $0)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

ROWS=$GIS_OPT_rows
COLS=$GIS_OPT_cols

g.region region=initial_region --q

# Full extents of current computational region; in meters, not pixels.
FULL_EW_EXTENT=`g.region -e | awk 'NR == 2 {printf "%i", $3}'`
FULL_NS_EXTENT=`g.region -e | awk 'NR == 1 {printf "%i", $3}'`

#echo "Full E-W extent is ${FULL_EW_EXTENT}".
#echo "Full N-S extent is ${FULL_NS_EXTENT}".
#
#exit 0

# Initial bounding box of computational region.
FULL_NORTH=`g.region -g | grep "^n=" | cut -d'=' -f2 | awk '{printf "%i", $1}'`
FULL_SOUTH=`g.region -g | grep "^s=" | cut -d'=' -f2 | awk '{printf "%i", $1}'`
FULL_EAST=`g.region -g | grep "^e=" | cut -d'=' -f2 | awk '{printf "%i", $1}'`
FULL_WEST=`g.region -g | grep "^w=" | cut -d'=' -f2 | awk '{printf "%i", $1}'`

# Fragment extents are in meters, not pixels.
# This is how big our moving raster export window will be.
FRAG_NS_EXTENT=$((${FULL_NS_EXTENT} / ${ROWS}))
FRAG_EW_EXTENT=$((${FULL_EW_EXTENT} / ${COLS}))

# Initialize beginning fragment bounds: northwest corner of input raster
# We will will move the export window east until it reaches the end of the input raster's easterly extent.
# Then it will move the window south one row, start at the western edge, and repeat.
START_WESTING=$FULL_WEST
START_NORTHING=$FULL_NORTH
START_EASTING_FLOAT=$((${START_WESTING} + ${FRAG_EW_EXTENT}))
START_EASTING=`echo $START_EASTING_FLOAT | awk '{printf "%0.f", $1}'`
START_SOUTHING_FLOAT=$((${START_NORTHING} - ${FRAG_NS_EXTENT}))
START_SOUTHING=`echo $START_SOUTHING_FLOAT | awk '{printf "%0.f", $1}'`

# Now initialize the export window with START bounds.

g.region n=$START_NORTHING s=$START_SOUTHING e=$START_EASTING w=$START_WESTING

CURRENT_EAST=$START_EASTING
CURRENT_WEST=$START_WESTING
CURRENT_NORTH=$START_NORTHING
CURRENT_SOUTH=$START_SOUTHING

if [[ -f split_region_bounds.txt ]] ; then rm split_region_bounds.txt ; fi

for ((CURRENT_ROW=1; CURRENT_ROW <= $ROWS; CURRENT_ROW++)) ; do

	for ((CURRENT_COL=1; CURRENT_COL<=$COLS; CURRENT_COL++)) ; do

	do	echo "$(mb.getregion)" | tee -a split_region_bounds.txt

		CURRENT_EAST=`expr ${CURRENT_EAST} + ${FRAG_EW_EXTENT}`
		CURRENT_WEST=`expr ${CURRENT_WEST} + ${FRAG_EW_EXTENT}`
	

		g.region n=$CURRENT_NORTH s=$CURRENT_SOUTH e=$CURRENT_EAST w=$CURRENT_WEST


		if [ "$CURRENT_EAST" -gt "$FULL_EAST" ] ; then
			if [ "$GIS_FLAG_v" -eq 1 ] ; then
				echo -e "\nReached the maximum east extent of $INPUT."
			fi

			break 1
		fi

	done

	CURRENT_NORTH=$(($CURRENT_NORTH-$FRAG_NS_EXTENT))
	CURRENT_SOUTH=$(($CURRENT_SOUTH-$FRAG_NS_EXTENT))
	CURRENT_WEST=$START_WESTING
	CURRENT_EAST=$START_EASTING
		
	g.region n=$CURRENT_NORTH s=$CURRENT_SOUTH e=$CURRENT_EAST w=$CURRENT_WEST

	
done

# Restore the region to the initial region we began with
g.region region=initial_region --q

if [ "$GIS_FLAG_v" -eq 1 ] ; then
	echo -e "\n================================================="
	echo -e "\n\nFinished.\n"
fi

exit 0


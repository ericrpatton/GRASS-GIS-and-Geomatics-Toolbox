##############################################################################
#
# MODULE:        smoothpatch_gridlist.sh 
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <Eric dot Patton at Canada dot ca>
# 
# PURPOSE:       To run r.smooth patch on a given list of Grass rasters,
#				 producing an output mosaic that will (hopefully) have smooth
#				 and less-noticeable edges.  
#
# COPYRIGHT:    (c) 2020-2023 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: February 14, 2023
#	by Author
#
# NOTE: All raster maps in the gridlist MUST be in the current Grass mapset for
# r.patch.smooth to be able to find them.
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
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

if [ "$#" -ne 2 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT list.txt resolution\n"
	exit 1
fi

# Check if we have r.patch.smooth installed.

if [ ! -x "$(which r.patch.smooth)" ] ; then
	echo "$SCRIPT: r.patch.smooth required, please install it from Grass addons using g.extension first." 2>&1
	exit 1
fi

LIST=$1
RES=$2

# NOTE: This script only works on raster maps that actually overlap, so before
# running the script, amalgamte all separate map sections together.

readarray -t gridlist < ${LIST}

COUNTER=0

while [[ -n ${gridlist[$COUNTER]} && -n ${gridlist[$(($COUNTER + 1))]} ]] ; do
	OUTPUT="smoothpatch_$(basename $LIST .txt)_$COUNTER_and_$(($COUNTER+1))"
	
	RAST_A=${gridlist[$COUNTER]}
	RAST_B=${gridlist[$(($COUNTER + 1))]}

	echo -e "\nProcessing array elements $COUNTER and $(($COUNTER + 1))"
	sleep 3

	echo -e "\nRaster A will be ${RAST_A}."
	echo "Raster B will be ${RAST_B}."
	sleep 3

	g.region rast=${RAST_A},${RAST_B} res=${RES} -a
	#g.region res=${RES} -a

	echo -e "\nRunning r.patch.smooth on rasters $COUNTER and $(($COUNTER + 1)); please standby...\n"
	sleep 2

	r.patch.smooth -s input_a=${RAST_A} input_b=${RAST_B} out=${OUTPUT} tr=3 para=11 diff=9 --v --o
	unset gridlist[$(($COUNTER + 1))] 
	gridlist[$(($COUNTER + 1))]=${OUTPUT}

	COUNTER=$(($COUNTER + 1))
done

exit 0

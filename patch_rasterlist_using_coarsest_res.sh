#! /bin/bash
#
# Created Aug 30, 2017
#
##############################################################################

SCRIPT=`basename $0`
echo -e "\n$SCRIPT\n"

for FILE in *.list ; do

	[[ -f "patchlist.txt" ]] && rm patchlist.txt

	echo -e "\n=============================================================="
	echo -e "\nWorking on file $FILE..."
	
	# The complete list of input rasters for this FILE.
	RASTERS=`cat $FILE | awk 'BEGIN {ORS=","} {print $1}' | sed 's/,$//'`

	# The MAX variable is the lowest resolution (and hence highest value)
	# resolution we have encountered so far. We set the initial MAX variable
	# to a value lower than all of the rasters in the FILE, so that the first
	# MAP in FILE will be guaranteed coarser resolution than it.
	MAX=1
	echo "Initial MAX res is $MAX."
	echo ""
	sleep 1
		
	for MAP in `cat ${FILE}` ; do
		RES=`r.info -g ${MAP} | grep ewres | cut -d'=' -f2`
		BC_CHECK=`bc <<< "$MAX < $RES"`
		
		if [ $BC_CHECK -eq 1 ] ; then
				MAX=$RES
			fi
		echo "Resolution of map $MAP is $RES."
	done
	
	echo -e "\nCoarsest resolution within list $FILE is ${MAX}m."
	
	# This awk statement rounds up to the next integer, no matter what decimal
	# portion is present in MAX.
	ROUNDED_RES=`awk '{printf "%.0f\n", $1 + 0.5}' <<< $MAX`
	echo -e "Using a rounded value of ${ROUNDED_RES}m.\n"
	
	# Now iterate through the input rasters, resampling to the rounded,
	# coarsest resolution of all input rasters.

	for RAST in `cat ${FILE}` ; do
	
		# With the -w switch, the aggregate uses the values from all input cells which
		# intersect the output cell, weighted according to the proportion of the source
		# cell which lies inside the output cell. This is slower, but produces a more
		# accurate result.
		echo -e "\nResampling $RAST to ${ROUNDED_RES}m ..."
		g.region rast=${RAST} res=${ROUNDED_RES} -a
		r.resamp.stats -w input=${RAST} output=${RAST}_resamp_${ROUNDED_RES}m --o --v
		echo "${RAST}_resamp_${ROUNDED_RES}m" >> patchlist.txt
	
	done

	# Set the region to that of all the input rasters
	echo -e "\nTotal region for all rasters in file $FILE: \n"
	g.region rast=${RASTERS} res=${ROUNDED_RES} -ap
	

	OUTPUT="`basename $FILE .list`_${ROUNDED_RES}m"
	echo -e "\nPatching input rasters together into output $OUTPUT;  standby..."
	r.patch in=${RASTERS} out=${OUTPUT} --v --o 

done

exit 0

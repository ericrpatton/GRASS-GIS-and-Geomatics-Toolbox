#! /bin/bash
#
############################################################################
#
# MODULE:        mb.tune_clean_params
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To create a series of random areas from an input raster from
# which to calculate optimal mbclean parameters for an MB-System datalist.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 2, 2021
# Last Modified: November 2, 2021
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

if [ "$#" -le 1 ] ; then
	echo -e "\nusage: $SCRIPT mb.tune_clean_params rastername datalist [number_of_random_points]\n"
	exit 1
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

INPUT=$1
DATALIST=$2
RAND=$3
SLEEP=0.5
RES=$(getres.sh ${INPUT})
[[ -z ${RAND} ]] && RAND=10

# Filename wrangling

BUFFER=${INPUT}_rand_points_buffer
BUFFER_NOCATS=${BUFFER}_nocats
BUFFER_NEWCATS=${BUFFER}_newcats
VECTOR=${INPUT}_rand_points
echo -e "Selecting random points...\n"
sleep ${SLEEP}
r.random in=${INPUT} raster=${INPUT}_rand vector=${VECTOR} npoints=${RAND} --o
echo -e "\nBuffering points...\n"
sleep ${SLEEP}
v.buffer in=${VECTOR} out=${BUFFER} dist=5000 --o --q 

v.category in=${BUFFER} out=${BUFFER_NOCATS} op=del --o --q 
v.category in=${BUFFER_NOCATS} out=${BUFFER_NEWCATS} op=add --o --q
sleep ${SLEEP}

for CAT in $(seq 1 ${RAND}) ; do 
	echo -e "\nExtracting category number ${CAT}...\n"
	sleep ${SLEEP}
	v.extract in=${BUFFER_NEWCATS} out=${BUFFER}_cat${CAT} cats=${CAT} --o --q
	echo -e "\nRegion for ${BUFFER}_cat${CAT}:\n"
	g.region vect=${BUFFER}_cat${CAT} res=${RES} -ap
	sleep ${SLEEP}

	BUFFER_DATALIST="${BUFFER}_cat${CAT}.mb-1"
	BUFFER_PROCESSED_DATALIST="$(basename $BUFFER_DATALIST .mb-1)p.mb-1"
	mbdatalist -F-1 -I ${DATALIST} -R$(mb.getregion) > ${BUFFER_DATALIST} 

	echo -e "\n\nPopulated the following files in datalist for CAT #${CAT}:\n"
	cat ${BUFFER_DATALIST} 

	sleep ${SLEEP}

	#for DEPTH_RANGE in 3 4 5 ; do
		for SLOPE_CHECK in 60.0 62.5 65.0 67.5 70.0 ; do

			# mbclean flags:
			# -A sets the range of acceptable depth values relative to the local median depth 
			# -C is the slope filter (degrees)
			# -D is the minimum and maximum allowed distances on which the flagging 
			#    algorithms will operate, as a percentage of local median depth.
			# -G is the acceptable depth percentage filter
			# -P is the acceptable speed range filter (km/hr)
			# -W is the geographic region filter
			# -X the value given zaps this number of beams from the port and starbaord edges
			# -Z is the 0 lat/long filter; probably redundant with -W

			GRID_BASENAME="${BUFFER}_cat${CAT}_A${DEPTH_RANGE}_C${SLOPE_CHECK}"
			TIFF="$(basename $GRID_BASENAME .grd).tif"
			GRASS_SD="$(basename $TIFF .tif)_sd"
		
			echo -e "\nRunning mbclean...\n"
#			mbclean -F-1 -I ${BUFFER_DATALIST} -W-180/-30/30/89 -P1.0/30 -D0.01/0.25 -A${DEPTH_RANGE} -C${SLOPE_CHECK}/2 -Z 
			mbclean -F-1 -I ${BUFFER_DATALIST} -W-180/-30/30/89 -P1.0/30 -D0.01/0.25 -C${SLOPE_CHECK}/2 -Z 
	
			sleep ${SLEEP}

			echo -e "\nRunning mbprocess...\n"
			mbprocess -C3 -F-1 -I ${BUFFER_DATALIST}
			mbdatalist -F-1 -I ${BUFFER_DATALIST} -Z 
			sleep ${SLEEP}
			
			echo -e "\nRunning mbgrid...\n"
			mbgrid -A2 -F1 -E${RES}/${RES}/meters! -I ${BUFFER_PROCESSED_DATALIST} -M -O ${GRID_BASENAME}
			sleep ${SLEEP}
		
			echo -e "\nRunning gdalwarp...\n"
			gdalwarp -overwrite -s_srs "EPSG:4326" -t_srs $(g.proj -jf | sed 's/+type=crs//') -tr ${RES} ${RES} -r bilinear -multi -wo NUM_THREADS=4 -of "GTiff" ${GRID_BASENAME}.grd ${TIFF}
			sleep ${SLEEP}

			echo -e "\n Importing into GRASS GIS...\n"
			r.in.gdal in=${TIFF} out=${GRASS_SD} --o -o --q
			sleep ${SLEEP}
			
			STDDEV=$(r.univar -g map=${GRASS_SD} --q | grep stddev | awk -F'=' '{print $2}')
			echo ""
			#echo "Results for Point with category #${CAT}: mbclean -A${DEPTH_RANGE} -C${SLOPE_CHECK} SD: ${STDDEV}" | tee -a ${INPUT}_stddev_results.txt
			echo "Results for Point with category #${CAT}: mbclean -C${SLOPE_CHECK} SD: ${STDDEV}" | tee -a ${INPUT}_stddev_results.txt
			
			echo -e "\n\n"
			sleep ${SLEEP}

			mbset -F-1 -I ${DATALIST} -PEDITSAVEMODE:0
			echo -e "\n\n"	
			sleep ${SLEEP}
			# Remove the edit save files from each file in the datalist so that
			# every subsequent iteration of this loop will not be reading and
			# processing on top of old edits. 

			# TO-DO: Remove the directory changing below; this is only for
			# testing at the moment (November 2, 2021)
				for FILE in $( cat ${DATALIST} | sed -e 's/..\///' | awk '{print $1}') ; do 
					(cd ../ ; find . -name "${FILE##*/}.esf*" -print | xargs -I {} rm -v {}) 
				done
			sleep ${SLEEP}
		done
	#done
	
done

# Cleanup
[[ "$?" -eq 0 ]] && rm ${BUFFER}_cat*[*.grd,*.tif]*

exit 0

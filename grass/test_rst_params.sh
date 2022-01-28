#! /bin/bash

# Ideally, use v.random to get a random distribution and number of points in
# the current regino, using the 'restrict' parameter to constrain the creation
# of points to a polygon of interest; v.hull is useful for generating a
# tightest-fitting polygon around raster data.
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

#if [ "$#" -ne 4 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
#	echo -e "\nusage: $SCRIPT random_points_file region_size resolution vector_to_rst\n"
#	exit 1
#fi
#
#POINTS=$1 
#SEMIREGION=$2
#RES=$3
VECT=$1

#v.to.db map=${POINTS} op=coor -p --q | awk -F'|' '{print $2, $3}' > temp_points.txt
#COUNTER=0
#while read COOR; do 
#	COUNTER=$(($COUNTER + 1 ))
#	
#	# I'm rounding the points to integer values to be able to do Bash
#	# addition/subtraction with them...shouldn't be a big problem for regional
#	# work.
#	EASTING=$(echo ${COOR} | awk '{printf "%d\n", $1}')
#	NORTHING=$(echo ${COOR} | awk '{printf "%d\n", $2}')
#
#	#echo "EASTING IS $EASTING."
#	#echo "NORTHING IS $NORTHING."
#	#sleep 2
#
#	echo -e "\nWorking on point number $COUNTER...\n"
#	g.region n=$(($NORTHING + $SEMIREGION )) s=$(($NORTHING - $SEMIREGION)) e=$(($EASTING + $SEMIREGION )) w=$(($EASTING - $SEMIREGION )) res=$RES -ap
#
#	#break
#
#	CLIPMAP="${POINTS}_clipregion_${COUNTER}"
#
#	v.in.region output=${CLIPMAP} type=area --o --v
#
#	CLIPOUT="${VECT}_rst_testpar_${COUNTER}"
#
#	echo -e "\nClipping vector $VECT wіth map $CLIPMAP...\n"
#	v.clip input=${VECT} clip=${CLIPMAP} output=${CLIPOUT} --v --o
#
#done < temp_points.txt
#echo -e "\nFinished creating clipped test regions." ; sleep 2

# Now run the interpolation
#PERMUTATIONS=$( echo $COUNTER * 16 | bc -l )
COUNTER=0

for MAP in $(g.list type=vect pat="${VECT}_rst_testpar_[5-8]") ; do
	for TENSION in 10 20 40 80 160 ; do
		for NPMIN in 50 100 150 200 400 600 ; do
			for SMOOTH in 0.5 1 2 4 8 16 ; do
				COUNTER=$(($COUNTER + 1 ))
				echo -e "\nWorking on map $MAP: #${COUNTER}, with tension $TENSION, npmin $NPMIN, and smoothing $SMOOTH...\n"
				g.region vect=${MAP} res=100 -a
				v.surf.rst input=${MAP} zcolumn=Depth elev="${MAP}_ten${TENSION}_npmin${NPMIN}_sm${SMOOTH}" nprocs=8 tension=${TENSION} npmin=${NPMIN} smooth=${SMOOTH} --v --o
			done
		done
	done
done

[ -f temp_points.txt ] && rm temp_points.txt 

echo -e "$SCRIPT: Done!" 

exit 0

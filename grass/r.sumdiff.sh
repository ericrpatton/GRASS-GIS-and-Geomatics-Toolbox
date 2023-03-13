#! /bin/bash

SCRIPT=$(basename $0)

if [ "$#" -ne 3 ] ; then
	echo -e "\nusage: $SCRIPT sourcemap comparemap operator ( i.e., +/- )\n"
	exit 0
fi

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SOURCE_MAP=$1
COMPARE_MAP=$2
OPERATOR=$3

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

g.region rast=${COMPARE_MAP}
if [[ ${OPERATOR} == "+" ]] ; then
	
	OUTPUT=Summed_${SOURCE_MAP}_${COMPARE_MAP}
else
	OUTPUT=Diff_${SOURCE_MAP}_${COMPARE_MAP}
fi

echo -e "\nWriting output map ${OUTPUT}..."
r.mapcalc "${OUTPUT} = ${SOURCE_MAP} ${OPERATOR} ${COMPARE_MAP}" --o --q

exit 0

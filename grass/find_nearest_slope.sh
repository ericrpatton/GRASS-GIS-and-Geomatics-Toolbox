#! /bin/bash
#
#
# find_nearest_slope.sh
#
# A script to help automate the popluation of a shoreline vector with the
# nearest slope value in another vector point file. 

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=$1

MAP="`g.list type=vect pat=CanCoast_Shoreline_V2_${INPUT}_polylines_to_points`"
echo -e "\n\nWorking on vector map $MAP...\n"


TO_MAP="`echo $MAP | awk -F'_' '{print $4}'`_slope_coast_strip_points"
OUTPUT="`basename $MAP _polylines_to_points`_closest_slope_connectors"
time v.distance from=${MAP} from_type=point from_layer=1 to=${TO_MAP} to_layer=1 to_type=point output=${OUTPUT} dmax=200 to_column=value column=Slope_Perc upload=to_attr --v --o

exit 0

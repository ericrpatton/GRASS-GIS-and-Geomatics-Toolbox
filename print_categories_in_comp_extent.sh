#! /bin/bash

INPUT="CanCoast_Shoreline_V2_nfld_polylines_to_points_with_NULL_Slope"

REGION_CENTER_EAST=`g.region -gc | grep center_easting | cut -d'=' -f2`
REGION_CENTER_NORTH=`g.region -gc | grep center_northing | cut -d'=' -f2`

SCANNING_DIST=`g.region -e | grep east | awk '{print $3}'`
v.what map=${INPUT} coor=${REGION_CENTER_EAST},${REGION_CENTER_NORTH} dist=${SCANNING_DIST} -m | grep Category | awk '{print $2}'

exit 0


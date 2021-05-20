#!/bin/bash

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

FROM=$1
TO=$2

# This script assumes the FROM vector map needs to have a column added to it to
# capture the attribute value being queried from the TO vector. Also, it is
# assumed that FROM vector was created via v.to.points, and has two layers.
# The first layer is mostly useless, so we will add the attributes being
# queried from v.distance to layer #2.

v.db.addcolumn map=$FROM layer=2 col="Slope_Deg int" --v --o 

v.distance from=${FROM} from_type=point from_layer=2 to=${TO} to_type=point to_layer=1 dmax=200 to_column=value column=Slope_Deg upload=to_attr output=${FROM}_connectors --o --v

exit 0

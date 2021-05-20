#! /bin/bash

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

INPUT=$1
VALUE=$2
COLUMN="Slope_Perc" 

for ITEM in `print_categories_in_comp_extent.sh` ; do v.db.update map=${INPUT} column=${COLUMN} value=${VALUE} where="cat=${ITEM}" --o --v ; done

exit 0

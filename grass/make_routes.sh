#!/bin/bash
#
# make_routes.sh - A script to format a text file containing latitude,
# longitude and ID to Regulus route format.
#
# Created: June 16, 2016
#
# Last Modified: April 27, 2018 (v.out.ogr parameters updated)
#
##############################################################################

# Expected input format: Longitude Latitude ID (space-delimited)

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\nUser break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks (signal list: trap -l):
trap "exitprocedure" 2 3 15

INPUT=$1
UTM_BASE="`basename $INPUT .txt`"
UTM_TEXT="${UTM_BASE}_UTM20.txt"

dos2unix ${INPUT}
echo ""

# Create Regulus Route 
awk -v INPUT=$INPUT 'BEGIN { 
	
	OFS="|"
	ID_PREV=0
	ID_CURRENT=501

	i=0
	j=0
	while((getline < INPUT) > 0) {
		array_lat[i]=$2
		array_long[i]=$1
		array_ID[i]=$3
		i++ 
	}

	close(INPUT)

	print INPUT"|"
} 

{ 
	ID_NEXT=(ID_CURRENT + 1)

	print ID_CURRENT, NR, "39", "0", array_ID[j], array_lat[j], array_long[j], "185.00000|185.00000|1|0|0|0|0.00000|0|0|99999|0|0", ID_PREV, ID_NEXT

	ID_PREV=ID_CURRENT
	ID_CURRENT=ID_NEXT
	ID_NEXT++
	j++

}' $INPUT > ${UTM_BASE}.rte

# Create csv
awk 'BEGIN {OFS=","} {print $1, $2, $3}' ${INPUT} > `basename $INPUT .txt`.csv

# Create UTM text version for import into GRASS
proj +proj=utm +datum=WGS84 +zone=20 < ${INPUT} | awk '{print $1, $2, $3}' > ${UTM_TEXT}

# Import into GRASS
v.in.ascii in=${UTM_TEXT} out=${UTM_BASE} sep=space columns="Easting double precision, Northing double precision, Name varchar(30)" --o --v

# Export UTM shapefile
v.out.ogr input=${UTM_BASE} format="ESRI_Shapefile" out=${UTM_BASE}.shp -se --o --v

exit 0

#! /bin/bash
#
# polygon_to_points.sh: A script to extract the vertices of a polygon and
# output the coordinates in Lat-Long.
#
##############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT vector_filename\n"
	exit 1
fi

INPUT=$1

v.type input=${INPUT} output=${INPUT}_line from_type=boundary to_type=line --o 
v.to.points --overwrite input=${INPUT}_line output=${INPUT}_points use=vertex layer=-1 --v --o 

# Note: To view the point map just created above, you need to select layer 2
# in the vector's properties.

v.db.addcolumn map=${INPUT}_points column="Easting double precision, Northing double precision" layer=2
v.to.db map=${INPUT}_points option=coor column="Easting, Northing" layer=2 --v --o 
v.db.select map=${INPUT}_points layer=2 | awk -F"|" 'NR > 1 {print $3, $4}' | proj -I -E -s -f '%0.6f' $(g.proj -jf | sed 's/+type=crs//') | awk 'BEGIN {printf "%-6s %-9s %-10s %-10s %-11s\n", "Point", "Easting", "Northing", "Latitude", "Longitude"} {printf "%-6d %-6.2f %7.2f %-2.6f %-2.6f\n", NR, $1, $2, $3, $4}' | tee ${INPUT}_coords.txt

exit 0

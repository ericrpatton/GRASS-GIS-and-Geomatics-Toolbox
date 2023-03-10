#! /bin/bash
#
# afile2lines.sh - A simple wrapper script to format Longitude, Latitude points
# into the projection of the current Grass project, and pass them Hamish
# Bowman's v.in.lines python script, creating Grass vector line files.
#
# Last Modified: June 6, 2016
# 
# Changelog:	- Updated parameters of v.in.lines and v.category to Grass 7
#				  usage (01-06-2016)
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=$1
SUFFIX=$(echo "$INPUT" | cut -d'.' -f2)

# Input expected is LONGITUDE LATITUDE TIMESTAMP; since the output from
# nmea2a.sh is TIMESTAMP, LATITUDE, LONGITUDE, rearrange the columns of the
# afile for coordinate conversion in proj.

awk '{print $3, $2, $1}' "${INPUT}" > TMP && mv TMP "${INPUT}"
proj "$(g.proj -jf | sed 's/+type=crs//')" "${INPUT}" | awk '{print $1, $2, $3}' | v.in.lines in=- sep=space output=TMP --o --v 

v.category input=TMP option=add output="$(basename "${INPUT}" ."${SUFFIX}")"_lines --o --v 
g.remove type=vect name=TMP -f

exit 0

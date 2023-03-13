#!/bin/bash
#
# Written by chatGPT!
#
# Date: January 4, 2023
#
###############################################################################

INPUT=$1

# Assign the arguments to variables
long_min=$(echo ${INPUT} | awk -F '/' '{print $1}')
long_max=$(echo ${INPUT} | awk -F '/' '{print $2}')
lat_min=$(echo ${INPUT} | awk -F '/' '{print $3}')
lat_max=$(echo ${INPUT} | awk -F '/' '{print $4}')

# Check if the bounding box is within the bounds
if awk -v lm=$long_min -v lM=$long_max -v ln=$lat_min -v lN=$lat_max 'BEGIN {if (lm >= -30 && lM <= -150 && ln >= 30 && lN <= 89.9) { print "1" }}'; then
    echo "Bounding box is within bounds"
else
    echo "Bounding box is out of bounds"
fi

exit 0

#!/bin/bash
#
#
# afile_decimate.sh - A script to create decimated navigation files at various
# levels.
#
# Author: Eric Patton
#
# Last Modified: June 9, 2016
#
#############################################################################

# This script expects output from a script such as nmea2.sh, or any similar
# script that produces a 3-column file with timestamp, latitude, and
# longitude.

IN_PREFIX=`echo $1 | cut -d. -f1`
OUT_PREFIX=`basename ${IN_PREFIX} _1s`

SUFFIX=`echo $1 | cut -d. -f2`

#awk '$1 % 10 == 0 {print $1, $2, $3}' $1 > ${OUT_PREFIX}_10s.${SUFFIX}
awk '$1 % 100 == 0 {print $1, $2, $3}' $1 > ${OUT_PREFIX}_60s.${SUFFIX}
#awk '$1 % 1000 == 0 {print $1, $2, $3}' $1 > ${PREFIX}_10min.${SUFFIX}

exit 0

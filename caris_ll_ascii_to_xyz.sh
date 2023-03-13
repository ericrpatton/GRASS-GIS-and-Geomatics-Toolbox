#! /bin/bash
#
# A quick script to reformat a Caris-exported ASCII xyz file from the garbled,
# GIS-unfriendly format they use to GRASS format.

INPUT=${1}

sed -e 's/N//' -e 's/W//' -e 's/-/ /g' ${INPUT} | pv | awk '{printf "-%2.6f %2.6f %0.3f\n", $4 + (($5 + ($6 / 60)) / 60), $1 + (($2 + ($3 / 60)) / 60),  $7}'  > $(basename ${INPUT} .txt)_reformatted.xyz

exit 0

#! /bin/bash

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=$1

xz -dcv ${INPUT} | lzip -cv - > "${INPUT%.*}.lz" && rm ${INPUT}

exit 0

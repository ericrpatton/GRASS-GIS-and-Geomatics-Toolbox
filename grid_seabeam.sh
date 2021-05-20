#! /bin/bash

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

REGION=$1

while [ -z "$REGION" ] ; do
	read -p "Input the gridding region (W/E/S/N): " REGION
done

mblist -F-1 -I datalist.mb-1 -D2 -R${REGION} | awk '{print $1, $2, $3}' | proj -f '%0.3f' +proj=utm +datum=WGS84 +ellps=WGS84 +zone=22 | awk '{print $1, $2, -$3}' > bathy.xyz

exit 0 

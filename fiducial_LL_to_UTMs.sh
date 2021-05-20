#! /bin/bash
#
#	A script to extract NAPL-type photo metadata fiducial coordinates from
#	Lat-Long to UTM easting and northings.

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

awk '/^NE/ {print $3, $2, $1}' $1 | proj -f '%0.6f' `g.proj -jf` +datum=WGS84 +ellps=WGS84 | awk '{print $3, $1, $2}' > `basename $1 .txt`_fiducials.txt 
awk '/^NW/ {print $3, $2, $1}' $1 | proj -f '%0.6f' `g.proj -jf` +datum=WGS84 +ellps=WGS84 | awk '{print $3, $1, $2}' >> `basename $1 .txt`_fiducials.txt
awk '/^SE/ {print $3, $2, $1}' $1 | proj -f '%0.6f' `g.proj -jf` +datum=WGS84 +ellps=WGS84 | awk '{print $3, $1, $2}' >> `basename $1 .txt`_fiducials.txt
awk '/^SW/ {print $3, $2, $1}' $1 | proj -f '%0.6f' `g.proj -jf` +datum=WGS84 +ellps=WGS84 | awk '{print $3, $1, $2}' >> `basename $1 .txt`_fiducials.txt

exit 0

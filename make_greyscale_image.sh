#! /bin/bash
#
# make_greyscale_inage.sh: A simple script to convert a raster image to
# greyscale colours, using the Imagemagick utility 'convert'. 
#
##############################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT image_name \n"
	exit 1
fi

IMAGE=$1
SUFFIX=`echo $IMAGE | cut -d'.' -f2`
OUTPUT=`basename ${IMAGE} .${SUFFIX}`_BW.${SUFFIX}

convert ${IMAGE} -set colorspace Gray -separate -average ${OUTPUT}

exit 0

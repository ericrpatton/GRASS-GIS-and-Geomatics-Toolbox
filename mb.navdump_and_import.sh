#! /bin/bash
#
# mb.navdump_and_import.sh - A wrapper script that exports point and line
# navigation using mb.navdump_points.sh and mb.navdump_lines.sh, and imports
# both of these into the current GRASS GIS project using v.in.mbpoints and
# v.in.mblines. The OUTPUT parameter is intended to be a basename that is further
# modified to distinguish the line output from the point output.
#
# Last Modified: September 5, 2018
#
##############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "-help" -o "$1" == "--help" ] ; then
	echo -e "\nusage: $SCRIPT datalist.mb-1 output_basename.txt w/e/s/n \n"
	exit 0
fi

# The datalist is the first parameter, the output navigation basename is the
# second. The script appends additional suffixes to the given basename in
# order to distinguish the point and line output from each other. The third
# parameter is the desired gridding region, which will default to the whole
# world if none is given.

case "$#" in
	
0) 
echo -e "\nusage: $SCRIPT datalist.mb-1 output_basename.txt w/e/s/n \n"
read -p "Enter the name of a datalist in the current directory: " DATALIST
read -p "Enter the name of the output basename (filename.txt): " OUTPUT
read -p "Give the desired gridding region (W/E/S/N), INFO for a bounds file, or NO to use world extent: " REGION
;;

1) DATALIST=$1
read -p "Enter the name of the output basename (filename.txt): " OUTPUT
read -p "Give the desired gridding region (W/E/S/N), INFO for a bounds file, or NO to use world extent: " REGION
;;

2) DATALIST=$1 OUTPUT=$2
read -p "Give the desired gridding region (W/E/S/N), INFO for a bounds file, or NO to use world extent: " REGION
;;

3) DATALIST=$1 OUTPUT=$2 REGION=$3
;;

*) echo -e "\nusage: $SCRIPT datalist.mb-1 output_basename.txt w/e/s/n \n"
exit 1
;;

esac

POINTS_OUT=`basename $OUTPUT .txt`_Points.txt
LINES_OUT=`basename $OUTPUT .txt`_Lines.txt

# If INFO was given as the REGION parameter, use mb.getinforegion to either
# a) use a pre-generated bounds file created from mb.info, or;
# b) run mb.info on the input datalist to make one, then use it.

if [ "$REGION" == "INFO" ] ; then
	REGION=`mb.getinforegion`
fi

# Do it!
mb.navdump_points.sh ${DATALIST} ${POINTS_OUT} ${REGION}
v.in.mbpoints ${POINTS_OUT}
mb.navdump_lines.sh ${DATALIST} ${LINES_OUT} ${REGION}
v.in.mblines ${LINES_OUT}

exit 0

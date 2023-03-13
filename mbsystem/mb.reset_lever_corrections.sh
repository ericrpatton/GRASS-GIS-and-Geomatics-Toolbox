#! /bin/bash
#
###############################################################################
#
# MODULE:        mb.reset_lever_corrections.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PUPOSE:		 A script to change the given lever arm correction in an
# MB-System .par file to zero.
#
# COPYRIGHT:     (c) 2021-2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
#
#
# Created: February 14, 2022
# Last Modified: February 15, 2022
#
###############################################################################

SCRIPT=$(basename $0)

INPUT=$1

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nUsage: $SCRIPT parfile [ Enter any of: VRUOFFSETX VRUOFFSETY VRUOFFSETZ SONAROFFSETX SONAROFFSETY SONAROFFSETZ ]\n"
	exit 0
fi

case "$2" in

	"VRUOFFSETX") 
		ADDRESS="83"
	;;

	"VRUOFFSETY")
		ADDRESS="84"
	;;

	"VRUOFFSETZ")
		ADDRESS="85"
	;;

	"SONAROFFSETX")	
		ADDRESS="86"
	;;

	"SONAROFFSETY")
		ADDRESS="87"
	;;

	"SONAROFFSETZ")
		ADDRESS="88"
	;;

	*)
		# If no specific lever offset is given, re-zero all of them
		ADDRESS="83,88"
	;;

esac

sed "${ADDRESS} s/[[:punct:]]*[[:digit:]][[:punct:]][[:digit:]]\{6\}/0.000000/" ${INPUT} > tmp && mv tmp ${INPUT}

exit 0

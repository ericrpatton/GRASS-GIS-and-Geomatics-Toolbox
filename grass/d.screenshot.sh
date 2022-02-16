#! /bin/bash
#
############################################################################
#
# MODULE:        d.screenshot.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at NRCan dash RNCan dot gc dot ca>
#
# PURPOSE:       A script to render a GRASS raster to an active wx monitor and
# export to png format. The script starts a wx monitor if needed.
#
# COPYRIGHT:     (c) 2022 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). 
# 
# Created:		  February 15, 2022
# Last Modified:  February 15, 2022
#
#############################################################################

SCRIPT=$(basename $0)

INPUT=$1

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT rastername \n"
	exit 0
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

g.region rast=${INPUT}

MONITOR_CHECK=$(d.mon -p --q)

if [[ $MONITOR_CHECK != "wx0" ]] ; then
	
	echo -e "No monitor running; starting wx0...\n"
	d.mon start=wx0 
fi

d.rast map=${INPUT}

exit 0

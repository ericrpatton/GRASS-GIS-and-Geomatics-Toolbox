#! /bin/bash
#
############################################################################
#
# MODULE:        fillṉulls.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <epatton at nrcan dot gc dot ca>
# 
# PURPOSE:		 To median-fill a Grass raster using a 3x3 nearest neighbor window.
# 
# COPYRIGHT:    (c) 2012-2016 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Last Modified: January 19, 2016
#   by Author
#
# CHANGELOG:	- Updated parameter names to conform to GRASS 7 usage (01-19-2016)
#
#############################################################################

if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

INPUT=${1}

echo -e "\nRunning 3x3 median-filter on $INPUT...please standby.\n"
r.neighbors input=${INPUT} output=fill.tmp method=median size=3 --o --v
r.mapcalc "${INPUT}_fill = if(isnull(${INPUT}), fill.tmp, ${INPUT})" --o

echo -e "\nProduced median-filled map ${INPUT}_fill."
g.remove -f type=rast name=fill.tmp --q

exit 0

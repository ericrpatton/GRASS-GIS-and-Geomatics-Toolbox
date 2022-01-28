#! /bin/bash
#
############################################################################
#
# MODULE:        r.checknull.sh for Grass 7.x
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       Check whether a raster file is completely null (prints 0), or
#				 not (print 1)
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 November 24, 2021
# Last Modified: November 24, 2021
#
#############################################################################
#
#%Module
#% description: Checks whether a raster file is completely null or not.
#%END

#%flag
#% key: i 
#% description: Invert the null check, report non-null rasters instead.
#%END

#%option 
#% key: input
#% type: string
#% gisprompt: old,cell,raster
#% required: yes
#% description: Input raster filename
#%END


if  [ -z "$GISBASE" ] ; then
    echo "You must be in GRASS GIS to run this program."
    exit 1
fi

if [ "$1" != "@ARGS_PARSED@" ] ; then
     exec g.parser "$0" "$@"
fi

SCRIPT=$(basename $0)

INPUT=$GIS_OPT_input
NULLCHECK=$(list_range.sh ${INPUT} | grep min | cut -d'=' -f2)

if [[ "$GIS_FLAG_i" -eq 1 ]] ; then
	[[ ! ${NULLCHECK} == "NULL" ]] && echo ${INPUT} 

else
	[[ ${NULLCHECK} == "NULL" ]] && echo ${INPUT} 

fi

exit 0

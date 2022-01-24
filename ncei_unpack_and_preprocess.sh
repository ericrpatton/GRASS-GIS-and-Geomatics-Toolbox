#!/bin/bash
#
############################################################################
#
# MODULE:        ncei_unpack_and_preprocess.sh
#
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
#		 		 <eric dot patton at canada dot ca>
# 
# PURPOSE:       To extract a tar.gz package downloaded from NOAA's NCEI
#				 bathymetry viewer website and unpack the gzipped swath files
#				 contained therein.		 		 
#
# COPYRIGHT:    (c) 2020-2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created: March 2, 2020
# Last Modified: Fberuary 12, 2021
#
#############################################################################	

SCRIPT=`basename $0`

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT:User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

if [ "$#" -ne 1 -o "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\n$SCRIPT ncei_tarpackage.tar.gz"
	exit 1
fi

PACKAGE=$1
BASEPATH=`pwd`
PACKAGE_DIR=`tar tzvf ${PACKAGE} | head -n1 | awk '{print $6}' | sed 's/\///'`
echo -e "\nExtracted a package name $PACKAGE_DIR."
sleep 3

VESSEL_LEVEL="${BASEPATH}/${PACKAGE_DIR}/insitu_ocean/trackline"
tar xzvf ${PACKAGE}

cd ${VESSEL_LEVEL}

for DIR in $(echo -e "$(dirname $(find . -name version2 -prune -o -name ancillary -prune -o -name metadata -prune -o -name *.gz* -print) | uniq)\n") ; do
	cd ${DIR}
	gunzip -vv *.gz
	cd -
done

exit 0 

#! /bin/bash
#
# wait_and_copy.sh - A simple script to act like a data logger; the copy
# command only runs when the SOURCE file is newer than the DESTINATION file or when
# the destination file is missing.
#
# Last modified: January 29, 2016
#
# CHANGELOG: - Notes improved, and header added (01-29-2016)
#
##############################################################################

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

SOURCE="/media/epatton/My_Passport1/EPATTON/Generic_GIS_layers/CanCoast/CanCoast2.0/InProgress/SLOPE_V2/CDEM_SLOPE/"
DESTINATION="/home/epatton/Imports"

while [ true ] ; do
	
	echo "Checking for new data in the source directory..."
	mv -uv ${SOURCE}*eqdc.tif ${DESTINATION}
	
	echo -e "\nSleeping for ten minutes before re-checking..."	
	echo ""
	sleep 10m

done

exit 0

#! /bin/bash
#
# wait_and_copy_posmv.sh - A simple script to act like a data logger; the copy
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

SOURCE='/run/user/1000/gvfs/smb-share:server=sn18272115025,share=posmv_logs/'
DESTINATION='/run/user/1000/gvfs/smb-share:server=10.248.9.38,share=mbback/Hudson_2015018/CARIS/TrueHeave/'

while [ true ] ; do
	
	echo "Checking for new rawdata file in the source directory..."
	cp -uv ${SOURCE}2015* ${DESTINATION}
	
	echo -e "\nSleeping for ten minutes before re-checking..."	
	echo ""
	sleep 10m

done

exit 0

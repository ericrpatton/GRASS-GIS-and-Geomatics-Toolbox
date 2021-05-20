#! /bin/bash
#
# wait_and_copy_rawdata.sh - A simple script to act like a data logger; the copy
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

SOURCE='/run/user/1000/gvfs/smb-share:server=sn18272115025,share=rawdata/'
DESTINATION='/run/user/1000/gvfs/smb-share:server=10.248.9.38,share=mbback/Hudson_2015018/CARIS/PreProcess/07-08/'

while [ true ] ; do
	
	echo "Checking for new rawdata files in the source directory..."
	mv -uv ${SOURCE}*.s7k ${DESTINATION}
	
	echo -e "\nSleeping for 5 seconds before re-checking...\n"
	sleep 5

done

exit 0

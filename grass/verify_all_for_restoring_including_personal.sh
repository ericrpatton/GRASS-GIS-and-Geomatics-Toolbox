#! /bin/bash
#
# verify_all_for_restoring_except_personal.sh - A script to check whether
# the local copy of an archive differs from the copy on the backup media
# (excluding the personal directory). Prints a list of local archives needing
# synchronization with the archive copy.
#
# Last Modified: March 28, 2017
#
# CHANGELOG: - Script created (04-08-2016) 
#			 - added general and public service directories (15-11-2016)
# 
###############################################################################

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\nUser break or similar caught; Exiting.\n" ; exit 1' 2 3 15

LIST="coderepo_verify.sh biblio_verify.sh home_verify.sh general_verify.sh public_service_verify.sh docs_verify.sh personal_verify.sh"

for SCRIPT in $LIST ; do
	
		echo -e "\n\n========================================================="
		echo -e "\nRunning $SCRIPT..."
		RESULT=`$SCRIPT | tail -n1 | cut -d':' -f2`
		echo -e "\n$SCRIPT: $RESULT\n"
		sleep 2
		DIFFS=`echo $RESULT | awk '{print $4}'`

		echo ""
		DIRNAME=`basename $SCRIPT _verify.sh`
		
		if [ $DIFFS -ne 0 ] ; then
			echo "$DIFFS differences found in the directory $DIRNAME."
			echo $DIRNAME >> restorelist.txt
		fi
		
done

if [ -f "restorelist.txt" ] ; then
	echo -e "\n========================================================="
	echo -e "\nThe following directories are out of synch:\n\n`cat restorelist.txt`\n"
	echo -e "=========================================================\n"
	rm restorelist.txt
fi

echo ""

exit 0


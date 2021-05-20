#! /bin/bash
#
# verify_all_except_personal_and_backup.sh -  A script to run all my backup
# scripts (excludes the Personal directory); it first checks whether there are
# any changes, and then does an incremental backup if so.
#
# Last Modified: March 28, 2017
#
###############################################################################

LIST="coderepo_verify.sh biblio_verify.sh public_service_verify.sh general_verify.sh home_verify.sh docs_verify.sh"

for SCRIPT in $LIST ; do
	
		echo -e "\n\n========================================================="
		echo -e "\nRunning $SCRIPT..."
		RESULT=`$SCRIPT | tail -n1 | cut -d':' -f2`
		echo -e "\n$SCRIPT: $RESULT\n"
		sleep 2
		DIFFS=`echo $RESULT | awk '{print $4}'`

		if [ $DIFFS -ne 0 ] ; then
			BACKUP=`basename $SCRIPT verify.sh`incr_backup.sh
			echo -e "\nBacking up changes...\n"
			sleep 2
			$BACKUP

		else
			echo -e "\n...No backup necessary."
			echo "========================================================="

		fi
done

backup_resource_files.sh

exit 0

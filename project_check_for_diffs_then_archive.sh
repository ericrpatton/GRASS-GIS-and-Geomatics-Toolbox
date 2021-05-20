#! /bin/bash
#
# check_for_diffs_then_archive.sh - a script to check a GRASS GIS project
# against the archived version using duplicity; if more than 30 diffs are
# found, do a full backup of the project; if between 1 and 30, do an
# incremental back; if there are no differences, exit.
#
# Last modified: January 29, 2016
#
# CHANGELOG: - script created (01-29-2016)
#
##############################################################################

PROJECT=$1
SCRIPT=$(basename $0) 
THRESHOLD=30

if [ -z "$PROJECT" ] ; then
	echo -e "$SCRIPT: Error: Please enter the name of a project to check in the current directory!"
	exit 1
fi

echo -e "\n-------------------------------------------------------------------------------------------"
echo -e  "Checking GRASS GIS project $PROJECT for differences against archived copy...please standby.\n"
DIFFS=`project_verify.sh ${PROJECT} | tail -n1 | awk -F, '{print $2}' | awk '{print $1}'`

if [ "$DIFFS" -gt "$THRESHOLD" ] ; then
	echo -e "\n$DIFFS differences found in local and archived versions of $PROJECT; performing full backup...\n\n"
	sleep 3
	project_full_backup.sh $PROJECT

elif [ "$DIFFS" -gt 0 -a "$DIFFS" -lt "$THRESHOLD" ] ; then
	echo -e "\n$DIFFS differences found in local and archived versions of $PROJECT; performing incremental backup...\n\n"
	sleep 3
	project_incr_backup.sh $PROJECT

else
	echo -e "\n$DIFFS differences found between local and archived version; no backup necessary\n\n"
fi

echo ""

exit 0

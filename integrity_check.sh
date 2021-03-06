############################################################################
#! /bin/bash
#
############################################################################
#
# MODULE:        integrity_check.sh
# 
# AUTHOR:   	 Eric Patton, Geological Survey of Canada (Atlantic)
# 		         <Eric dot Patton at Canada dot ca>
#
# PURPOSE:       To verify the integrity and caclulate the SHA256 cryptographic
# hash of lzipped files in the current directory, and write these results to
# the screen and a report.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 June 4, 2021
# Last Modified: June 4, 2021
#############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT: verifies the integrity and calculates the SHA256 cryptographic hash of lzipped files in the current directory, and writes these results to the screen and a report.  \n"
	exit 0
fi

INPUT=$1

# If no argument was given for the input file, use a wildcard pattern to run
# this script on all .lz files in the current directory.

[[ -z ${INPUT} ]] && INPUT="*.lz" 

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

echo -e "\n----------------------------------------------------------------------------------------" > integrity_check_and_sha256sum_report.txt
echo -e "\nDATE CREATED: $(date '+%c')\n" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "Verification Command Used: 'lzip -tv'" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "Version: $(lzip --version | awk 'NR == 1 {print $0}')" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "\n----------------------------------------------------------------------------------------\n" >> integrity_check_and_sha256sum_report.txt

echo -e "LZIP FILE INTEGRITY REPORT:\n" >> integrity_check_and_sha256sum_report.txt
echo -e "\nChecking integrity of lzip files in current directory...\n"
sleep 2

parallel lzip -tv 2>&1 ::: ${INPUT} | tee -a integrity_check_and_sha256sum_report.txt

echo -e "\n----------------------------------------------------------------------------------------" >> integrity_check_and_sha256sum_report.txt
echo -e "\nSHA256SUMs:\n" >> integrity_check_and_sha256sum_report.txt
echo -e "Verify with: 'sha256sum -c --ignore-missing integrity_check_and_sha256sum_report.txt'\n" >> integrity_check_and_sha256sum_report.txt
echo -e "\nCalculating sha256 checksums...\n"

parallel sha256sum 2>&1 ::: ${INPUT} | tee -a integrity_check_and_sha256sum_report.txt && echo -e "\nDone."

echo -e "\n\nVerifying checksums:" | tee -a integrity_check_and_sha256sum_report.txt 
echo -e "Date: $(date '+%c')\n" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "----------------------------------------------------------------------------------------\n" >> integrity_check_and_sha256sum_report.txt

sha256sum -c --ignore-missing  integrity_check_and_sha256sum_report.txt 2>/dev/null | tee -a temp_check.txt
cat temp_check.txt >> integrity_check_and_sha256sum_report.txt && rm temp_check.txt && echo -e "\nDone."
echo -e "\n========================================================================================\n" >> integrity_check_and_sha256sum_report.txt

exit 0

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
# hash of bzip2-ed files in the current directory, and write these results to
# the screen and a report.
#
# COPYRIGHT:     (c) 2021 by Eric Patton
#
#                This program is free software under the GNU General Public
#                License (>=v3). Read the file COPYING that comes with GRASS
#                for details.
# 
# Created:		 June 4, 2021
# Last Modified: May 31, 202May 31, 2022
#############################################################################

SCRIPT=$(basename "$0")

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: $SCRIPT: verifies the integrity and calculates the SHA256 cryptographic hash of bzip-ed files in the current directory, and writes these results to the screen and a report.  \n"
	exit 0
fi

# What to do in case of user break:
exitprocedure()
{
	echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n"
	exit 1
}

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

FILE_COUNT=$(ls -1 *.bz2 2>/dev/null | wc -l)

[[ ${FILE_COUNT} -eq 0 ]] && echo -e "\n$SCRIPT: Error: No bzip files in the current directory!" && exit 1

[[ -f "tmp_check.txt" ]] && rm tmp_check.txt
[[ -f "tmp_sha.txt" ]] && rm tmp_sha.txt
[[ -f "tmp_verify.txt" ]] && rm tmp_verify.txt

# Setup clean exit for Ctrl-C or similar breaks.
trap 'exitprocedure' 2 3 15

echo -e "----------------------------------------------------------------------------------------" > integrity_check_and_sha256sum_report.txt
echo -e "\nDATE CREATED: $(date '+%c')\n" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "Verification Command Used: 'bzip2 -tv'" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "Version: bzip2 Version 1.0.8, 13-Jul-2019" | tee -a integrity_check_and_sha256sum_report.txt
echo -e "\n----------------------------------------------------------------------------------------\n" >> integrity_check_and_sha256sum_report.txt

echo -e "BZIP2 FILE INTEGRITY REPORT:\n" >> integrity_check_and_sha256sum_report.txt
echo -e "\nChecking integrity of bzip2 files in current directory...\n"
sleep 2

parallel -j16 bzip2 -tv 2>&1 ::: *.bz2 | tee -a tmp_check.txt
sort tmp_check.txt >> integrity_check_and_sha256sum_report.txt

echo -e "\n----------------------------------------------------------------------------------------" >> integrity_check_and_sha256sum_report.txt
echo -e "\nSHA256SUMs:\n" >> integrity_check_and_sha256sum_report.txt
echo -e "Verify with: 'sha256sum -c --ignore-missing integrity_check_and_sha256sum_report.txt'\n" >> integrity_check_and_sha256sum_report.txt
echo -e "\nCalculating sha256 checksums...\n"

parallel -j16 sha256sum 2>&1 ::: *.bz2  | tee -a tmp_sha.txt && echo -e "\nDone."
sort -k2 tmp_sha.txt >> integrity_check_and_sha256sum_report.txt

echo -e "\n----------------------------------------------------------------------------------------" >> integrity_check_and_sha256sum_report.txt
echo -e "\nVerifying checksums:" | tee -a integrity_check_and_sha256sum_report.txt 
echo -e "Date: $(date '+%c')\n" | tee -a integrity_check_and_sha256sum_report.txt

sha256sum -c --ignore-missing tmp_sha.txt 2>/dev/null | tee -a tmp_verify.txt
sort tmp_verify.txt >> integrity_check_and_sha256sum_report.txt && rm tmp_check.txt tmp_sha.txt tmp_verify.txt &>/dev/null && echo -e "\nDone."
echo -e "\n========================================================================================" >> integrity_check_and_sha256sum_report.txt

exit 0

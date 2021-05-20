#! /bin/bash
# 
# This script concatenates a series of Knudsen KEA format files into one.
# 
# Created by: Eric Patton, GSC-A
#
# Date Created: July 29, 2020
# 
###################################################################################

SCRIPT=$(basename $0)

# Setup clean exit for Ctrl-C or similar breaks.
trap 'echo -e "\n\n$SCRIPT: User break or similar caught; Exiting.\n" ; exit 1' 2 3 15

read -p "Enter a kea wildcard search pattern: " PATTERN
read -p "Enter the Julian Day to use for concatenation: " JDAY
OUTPUT="JD${JDAY}.kea"

cat ${PATTERN} > ${OUTPUT}

# Remove the column header lines from the concatenated KEA file.
awk -F, '$1 == "ddmmyyyy" {next} { print $0}' ${OUTPUT} > tmp && mv tmp ${OUTPUT}

echo -e "\nDone."

exit 0

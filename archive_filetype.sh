#! /bin/bash
#
# This script takes a filename extension pattern as input and uses GNU parallel
# to archive these filetypes using all CPUs on the system.

PATTERN=${1}

parallel --eta -j8 lzip -v ::: ${PATTERN}

exit 0

#! /bin/bash
#
#	This script assumes the 1st column of the input file contains the
#	timestamp.

awk '$1 % 10 == 0 {printf "%0.6f %0.6f %d\n", $1, $2, $3}' $1        

exit 0

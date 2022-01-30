#! /bin/bash
#
#
# This script prints a user-supplied random number of filenames from the current
# directory.

NUMBER=$1

ls -1 | shuf -n${NUMBER} 

exit 0

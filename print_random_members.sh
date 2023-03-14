#!/bin/bash

# This script prints a user-supplied random number of filenames from the current
# directory, or, if no input parameter was provided, prints a random selection
# of members from standard input between 5 and 10.
#
# Created by ChatGPT, January 4, 2023
#
###############################################################################

SCRIPT=$(basename $0)

if [ "$1" == "-H" -o "$1" == "-h" -o "$1" == "--help" -o "$1" == "-help" ] ; then
	echo -e "\nusage: [$SCRIPT [number_of_members_to_print] | - ]"
	echo "If no parameters are provided, script reads from standard input."
	exit 0
fi

# Check if the user provided a value for 'n'
if [ -z "$1" ]

then
    # If not, read from standard input and use 'shuf' to select a random
    # number of elements between 5 and 10
    input=$(cat | shuf -n $((RANDOM % 6 + 5)))
else
    # If 'n' was provided, use it to select 'n' random elements from the
    # current working directory
    input=$(ls | shuf -n $1)
fi

# Split the input into an array
array=($input)

# Print the array
echo "${array[@]}"

exit 0

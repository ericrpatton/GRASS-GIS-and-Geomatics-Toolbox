#! /bin/bash

# Rounds decimal portions of numbers down to the next whole integer.

INPUT=$1
echo ${INPUT} | awk '{print ($0-int($0)>0)?int($0)+1:int($0)}'

exit 0

#! /bin/bash

INPUT=$1
r.info  ${INPUT} -e | grep comments | sed 's/\\//g' | sed 's/ //g' | sed 's/"//g' | awk 'BEGIN {RS=","} $1 ~ /^1/ {print $1}'

exit 0

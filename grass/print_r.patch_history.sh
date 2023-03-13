#! /bin/bash

INPUT=$1
r.info -e ${INPUT} | grep comments | sed 's/\\//g' | sed 's/"//g' | cut -d'=' -f3 | awk 'BEGIN {RS=","} {print $1}'

exit 0

#! /bin/bash

VECTOR=$1

v.info -c map=${VECTOR} --q | awk -F'|' 'BEGIN {ORS=","}  !/cat/ {print $2}' | sed 's/,$//'

exit 0

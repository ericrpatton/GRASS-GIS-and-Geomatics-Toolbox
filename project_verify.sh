#!/bin/bash

DIR=$1
MEDIA=$2

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/${MEDIA}/Projects/${DIR} /home/epatton/Projects/${DIR}

exit 0

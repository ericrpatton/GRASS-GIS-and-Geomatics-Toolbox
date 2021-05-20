#!/bin/bash

test -x $(which duplicity) || exit 0

DIR=$1
MEDIA=$2

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch ${DIR} file:///media/epatton/${MEDIA}/Projects/${DIR}

exit 0 

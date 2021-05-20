#!/bin/bash

[ $(which duplicity) ] || exit 0

DIR=$1
MEDIA=$2
DEST="file:///media/epatton/${MEDIA}/Projects/${DIR}"

duplicity -v5 full --no-encryption --progress --asynchronous-upload --allow-source-mismatch ${DIR} ${DEST}
duplicity -v5 remove-all-but-n-full 3 --force ${DEST}

exit 0 

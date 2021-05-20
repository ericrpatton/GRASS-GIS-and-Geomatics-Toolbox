#!/bin/bash

test -x $(which duplicity) || exit 0

DIR=$1

duplicity -v5 full --no-encryption --progress --asynchronous-upload --allow-source-mismatch ${DIR} file:///media/epatton/My\ Passport/Projects/${DIR}
duplicity -v5 remove-all-but-n-full 3 --force file:///media/epatton/My\ Passport/Projects/${DIR}

exit 0 

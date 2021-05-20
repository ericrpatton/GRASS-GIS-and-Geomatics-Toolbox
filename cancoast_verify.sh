#! /bin/bash

DIR=$1

duplicity -v5 verify --no-encryption --progress --asynchronous-upload  file:///media/epatton/My\ Passport/Projects/${DIR} ${DIR}

exit 0

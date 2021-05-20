#! /bin/bash

DIR=$1
MEDIA=$2 

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/${MEDIA}/Projects/${DIR} /home/epatton/Projects/${DIR}

exit 0

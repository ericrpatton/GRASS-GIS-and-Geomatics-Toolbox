#! /bin/bash

DIR=$1
NPROC=$(nproc)

tar -cvf - ${DIR} | pbzip2 -c -v -p${NPROC} > ${DIR}.tar.pbzip2

exit 0

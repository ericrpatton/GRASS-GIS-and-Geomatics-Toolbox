#! /bin/bash

DIR=$1
NPROC=$(nproc)

tar -cvf - ${DIR} | plzip -n${NPROC} > ${DIR}.tar.plzip

exit 0

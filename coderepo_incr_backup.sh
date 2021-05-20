#!/bin/bash

test -x $(which duplicity) || exit 0

DIR=$1

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/coderepo/ file:///media/epatton/My_Passport1/EPATTON/coderepo/

exit 0 

#!/bin/bash

test -x $(which duplicity) || exit 0

DIR=$1

duplicity -v5 full --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/coderepo file:///media/epatton/My_Passport1/EPATTON/coderepo/
duplicity -v5 remove-all-but-n-full 3 --force file:///media/epatton/My_Passport1/EPATTON/coderepo/

exit 0 

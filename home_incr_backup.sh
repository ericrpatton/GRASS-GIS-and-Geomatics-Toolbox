#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/GSCA/2020-2021 file:///media/epatton/My_Passport1/EPATTON/GSCA/2020-2021

exit 0

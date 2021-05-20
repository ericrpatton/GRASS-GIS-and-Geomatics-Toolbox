#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/GSCA/Public_Service file:///media/epatton/My_Passport1/EPATTON/GSCA/Public_Service

exit 0

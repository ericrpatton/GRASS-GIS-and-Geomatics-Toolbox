#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/GSCA/General_Forms_and_Documents file:///media/epatton/My_Passport1/EPATTON/GSCA/General_Forms_and_Documents

exit 0

#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/Documentation file:///media/epatton/My_Passport1/EPATTON/Documentation

exit 0


#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v5 full --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/Documentation file:///media/epatton/My_Passport1/EPATTON/Documentation

duplicity -v5 remove-all-but-n-full 3 --force file:///media/epatton/My_Passport1/EPATTON/Documentation

exit 0

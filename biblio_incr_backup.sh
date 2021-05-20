#!/bin/bash

test -x $(which duplicity) || exit 0

duplicity -v8 incr --no-encryption --progress --asynchronous-upload --allow-source-mismatch /home/epatton/GSCA/Bibliography file:///media/epatton/My_Passport1/EPATTON/GSCA/Bibliography

exit 0

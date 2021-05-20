#! /bin/bash

rm -rfv /home/epatton/Documentation

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/Documentation /home/epatton/Documentation

exit 0 

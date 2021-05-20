#! /bin/bash

rm -rfv /home/epatton/Personal

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/Personal /home/epatton/Personal

exit 0 

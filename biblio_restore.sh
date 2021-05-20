#! /bin/bash

rm -rfv /home/epatton/GSCA/Bibliography
sleep 1.5

duplicity -v8 --allow-source-mismatch --progress --force --no-encryption file:///media/epatton/My_Passport1/EPATTON/GSCA/Bibliography /home/epatton/GSCA/Bibliography

exit 0 


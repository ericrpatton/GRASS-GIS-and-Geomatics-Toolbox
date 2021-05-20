#!/bin/bash

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/My_Passport1/EPATTON/GSCA/Bibliography /home/epatton/GSCA/Bibliography

exit 0

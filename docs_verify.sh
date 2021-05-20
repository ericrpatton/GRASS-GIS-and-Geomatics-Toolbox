#!/bin/bash

duplicity -v5 --no-encryption --allow-source-mismatch verify --compare-data file:///media/epatton/My_Passport1/EPATTON/Documentation /home/epatton/Documentation

exit 0

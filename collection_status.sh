#!/bin/bash

DIR=$1

duplicity -v5 collection-status file:///media/epatton/My_Passport1/EPATTON/Projects/${DIR}

exit 0

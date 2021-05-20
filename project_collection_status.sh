#!/bin/bash

PROJECT=$1
MEDIA=$2

duplicity -v5 collection-status file:///media/epatton/${MEDIA}/Projects/${PROJECT}

exit 0

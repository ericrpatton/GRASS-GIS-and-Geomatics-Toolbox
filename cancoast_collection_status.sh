#!/bin/bash

PROJECT=$1

duplicity -v5 collection-status file:///media/epatton/My\ Passport/Projects/${PROJECT}

exit 0


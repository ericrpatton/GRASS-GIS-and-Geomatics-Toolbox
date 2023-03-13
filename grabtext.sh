#!/bin/bash

INPUT=$(xclip -o)

FILE="$HOME/Desktop/catcher.txt"

echo "${INPUT}" >> ${FILE}

if [[ "$?" -eq 0 ]] ; then notify-send "Text snippet added to catcher.txt!"
else
	notify-send "Failed to add text snippet!"
fi

exit 0

#!/bin/bash

xdotool getmouselocation | grep -oP "[0-9]+ y:[0-9]+" | sed 's/ y:/,/' | tr -d '\n' | xsel --clipboard

exit 0

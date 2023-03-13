#! /bin/bash

# If there is an internal PC speaker, the command below should work.
#notify-send "GRASS GIS" "Process FAILED" && beep -f 440 -l 350 ; beep -f 420 -l 350 ; beep -f 400 -l 350 ; beep -f 380 -l 850 

notify-send "Process FAILED" && mpv --no-terminal --no-audio-display /home/epatton/coderepo/Sounds/16_-_Game_Over.mp3 

exit 0

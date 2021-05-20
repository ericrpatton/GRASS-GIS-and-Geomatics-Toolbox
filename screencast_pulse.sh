#! /bin/bash

# This is the scrip that xfwm4 will run when the hotkey is pressed.

if [[ -f ~/output.mkv ]] ; then
	n=1
	while [[ -f $HOME/output_$n.mkv ]] ; do
		n="$((n+1))"
	done 
	filename="$HOME/output_$n.mkv"
else
	filename="$HOME/output.mkv"
fi

# The actual ffmpeg command:

ffmpeg -y -f x11grab -s $(xdpyinfo  | grep dimensions | awk '{print $2;}') \
	-i :0.0 -f alsa -i default $filename

# Note: To capture video from the webcam use video0 with the -i flag
	
exit 0

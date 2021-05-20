#! /bin/bash

# Feed script a URL.
# If an image, it will view in feh.
# If a video or gif, it will view in mpv
# If a music file or pdf, it will download,
# otherwise it open in the browser.

ext="${1##*.}"
mpvFiles="mkv mp4 gif"
fehFiles="png jpg jpeg jpe JPG"
wgetFiles="mp3 flac opus mp3?source=feed pdf"

if echo $fehFiles | grep -w $ext > /dev/null; then
	nohup feh "$1" >/dev/null 
elif echo $mpvFiles | grep -w $ext > /dev/null; then
	nohup mpv --loop --quiet "$1" > /dev/null; 
elif echo $wgetFiles | grep -w $ext > /dev/null; then
	nohup wget "$1" >/dev/null 
else
	nohup $BROWSER "$1" >/dev/null 
fi

exit 0

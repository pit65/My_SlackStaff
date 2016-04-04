#!/bin/bash

set -x
# Generates an ffmpeg command line for capturing a given X11 window.
# Usage: $0 [optional output file name]
# It will prompt you to click on the window you want to capture.
# Output is simply echoed, for use in copy/pasting (adjusting/adding
# parameters as needed).
# Tip: the command uses screen coordinates, so do not resize or move
# the target window once capturing as begun.
echo "Click the window to capture..."

tmpfile=/tmp/screengrab.tmp.$$
trap 'touch $tmpfile; rm -f $tmpfile' 0

xwininfo > $tmpfile 2>/dev/null
left=$(grep 'Absolute upper-left X:' $tmpfile | awk '{print $4}');
top=$(grep 'Absolute upper-left Y:' $tmpfile | awk '{print $4}');
width=$(grep 'Width:' $tmpfile | awk '{print $2}');
height=$(grep 'Height:' $tmpfile | awk '{print $2}');
geom="-geometry ${width}x${height}+${left}+${top}"
echo "Geometry: ${geom}"
size="$[$[${width}/2]*2]x$[$[${height}/2]*2]"
pos="${left},${top}"
echo "pos=$pos size=$size"
DESTINATION="$HOME/Desktop"
out="$DESTINATION/$(date +"%m%d%Y_%H%M%S")_screencast.mp4"
vid="-vcodec libx264 -preset veryfast  -crf 20    -threads 0  -x264opts rc_lookahead=30:ref=3:trellis=1:mixed_refs:ssim  -vf  mp=eq2=1:1.1:0:1.2"
#test -f $out && rm $out
aud="-f alsa -i pulse -c:a libfaac -q:a 60" 
framerate=25
echo "# ffmpeg command"
 sleep 2;  # give caller time to switch to captured window
 ffmpeg -f x11grab \
    -r ${framerate} \
    -s ${size} \
    -i ${DISPLAY-0:0}+${pos} \
    $aud \
    $vid \
    $out
 #killall -INT -w ffmpeg  
 

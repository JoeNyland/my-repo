#!/bin/sh

for file in *.mp4
    do ffmpeg -i "$file" -vcodec:copy mpeg4 -vtag xvid -b:v 1200k -acodec libmp3lame -b:a 128k "${file[@]/%mp4/avi}"
done

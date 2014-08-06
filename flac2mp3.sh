#!/bin/sh

for file in *.flac
do
    ffmpeg -loglevel error -i "$file" -qscale:a 0 "${file[@]/%flac/mp3}"
    echo "Converted ${file}..."
done
tput bel
echo "Completed converting $(ls *.flac | wc -l) FLAC file(s)."


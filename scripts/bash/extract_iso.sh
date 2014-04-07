#!/bin/bash

if [[ -z "$1" ]]
then
    echo "You must provide the directory containing .iso files."
    exit 1000
fi

for file in $1/*.iso
    do
    filename=`basename "$file"`
    filename="${filename%.*}"
    echo "Extracting `basename \"$file\"`"
    mountpoint=`hdiutil mount "$file" | awk '{ print $2 }'`
    mkdir "Movies/raw/$filename"
    cp -rfv $mountpoint/* "Movies/raw/$filename"
    hdiutil unmount $mountpoint
    echo ;
done

#!/bin/bash

# Sync iTunes music to 
# Takes the source directory of iTunes Music as $1 and the destination as $2, formatted as remotehost:/remote/location

switches="-Ovruthmaog --delete --exclude=._* --exclude=.AppleDB*"
src=$1
dst=$2

if rsync $switches "$src" "$dst"
then
    echo "iTunes sync to  completed"
else
    echo "iTunes sync to  failed"
    exit 1
fi

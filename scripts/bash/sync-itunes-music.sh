#!/bin/bash

# Sync iTunes music to 
# Takes the source directory of iTunes Music as $1 and the destination as $2, formatted as remotehost:/remote/location

switches="-Ovruthmaog --delete --exclude=._* --exclude=.AppleDB*"
src=$1
dst=$2

if pmset -g | grep AC | grep "*" > /dev/null        # Check that we are running on AC power
then
    if rsync $switches "$src" "$dst"
    then
        echo "iTunes music sync to  completed"
        exit 0
    else
        echo "iTunes music sync to  failed"
        exit 1
    fi
else
    echo "iTunes music sync to  not run due to the system not being connected to AC power"
fi

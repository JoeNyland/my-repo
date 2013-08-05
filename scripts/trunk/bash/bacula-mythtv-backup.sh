#!/bin/bash
# Script to sync MythTV recordings from  to USB backup HDD on /mnt/backup1.

# General settings
SRC=/var/lib/mythtv/recordings                                  # The directory containing the MythTV recordings directory.
DST=/mnt/backup1/MythTV                                         # Destination directory

# Rsync settings
SWITCHES="-OvruEthm --delete"                                   # Rsync switches.
EXCLUDE="--exclude=._* --exclude=.AppleDB* --exclude=livetv/"   # Excluded files.

rsync $SWITCHES $SRC/ $DST/ $EXCLUDE

#!/bin/bash
# Script to sync MythTV recordings from RAID array on /mnt/data to USB backup HDD on /mnt/backup1.
# Note: This script is called by Bacula

# General settings
MOUNT=/mnt/data/mythtv														# Where the MythTV recordings directory is located.
BACKUPDRIVE=/mnt/backup1													# Where the USB backup HDD is mounted.

# MythTV overrides
OVER="--exclude='livetv/*'"													# MythTV specific overrides to Rsync (e.g. excluded directories).

# Rsync settings
STDSWITCHES="-vruEthm --delete"												# Standard Rsync switches.
STDEXCLUDE="--exclude='._*' --exclude='.AppleDB*' --exclude='lost+found' "	# Standard excluded files.

SRCDIR=MythTV
SRC=$MOUNT
DSTDIR=$SRCDIR
DST=$BACKUPDRIVE/$DSTDIR

rsync $STDSWITCHES $SRC/ $DST/ $STDEXCLUDE $OVER

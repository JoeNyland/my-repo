#!/bin/bash
# Script to sync files from RAID array on /mnt/array to USB backup HDD on /mnt/backup.

# General settings
ARRAY=/mnt/array															# Where the RAID array is mounted.
BACKUPDRIVE=/mnt/backup1													# Where the USB backup HDD is mounted.

############################################################################################################

# MythTV overrides
OVER="--exclude='livetv/*'"													# MythTV specific overrides to Rsync (e.g. excluded directories).

# Rsync settings
STDSWITCHES="-vruEthm --delete"												# Standard Rsync switches.
STDEXCLUDE="--exclude='._*' --exclude='.AppleDB*' --exclude='lost+found' "	# Standard excluded files.

# Logger settings
STDLOGGER="-sp cron.info"													# Standard logger switches

############################################################################################################

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1000
fi

if [ ! -z "$1" ]; then 
	SRCDIR=$1
else
	echo "You have not provided the name of the directory that you would like to sync.";
	echo ;
	echo "Correct syntax is:";
	echo "`hostname -s`:-$ ./array-backup.sh <directory name to sync>";
	exit 1000;
fi
SRC=$ARRAY/`echo $SRCDIR | sed -e 's/\(.*\)/\L\1/'`
DSTDIR=$SRCDIR
DST=$BACKUPDRIVE/$DSTDIR
LOGGERTAG=" -t $SRCDIR-backup"

rsync $STDSWITCHES $SRC/ $DST/ $STDEXCLUDE $OVER | logger $STDLOGGER $LOGGERTAG
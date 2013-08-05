#!/bin/bash

# This script archives shared data from 's RAID array to a 2 disk HDD archive.
#
# There are two functions to the script:
#
# Archive:
# This function is called by supplying either -a or --archive when calling this script. This archives all data from the chosen $DATA directory below to the first disk in the archive volume which is specified by the $VOLUME variable below.
#
# Sync:
# This function is called by supplying either -s or --sync when calling this script. This syncs all data from $DRIVE1 to $DRIVE2 in the archive volume which is specified by the $VOLUME variable below.
#

# General settings
DATA=/mnt/data/shared
VOLUME=vol1
DRIVE1=drive1
DRIVE2=drive2

# Rsync settings
SWITCHES="-OvruEthm"                                                                     # Rsync switches
EXCLUDE="--exclude=._* --exclude=.AppleDB* --exclude=lost+found --exclude=Downloads"     # Excluded files

# Error function definition
error_func() {
		case $1 in
		101)
		echo [ERROR] $0: Erorr code 101: Failed to archive data from $DATA to /mnt/archive/$VOLUME/$DRIVE1
		exit 101
		;;
		102)
		echo [ERROR] $0: Error code 102: Failed to archive data from /mnt/archive/$VOLUME/$DRIVE1 to /mnt/archive/$VOLUME/$DRIVE2
		exit 101
		;;
		*)
		echo An unidentified error occurred
		echo usage: $0 [-a\|--archive] [-s\|--sync]
		exit 103
		;;
		esac
	}

# Main script
case $1 in
	-a|--archive)
		SRC=$DATA/
		DST=/mnt/archive/$VOLUME/$DRIVE1/
	    echo [INFO] SharedData archive selected
	    echo [INFO] Archiving data from $SRC to $DST
		if rsync $SWITCHES $SRC $DST $EXCLUDE
		then
		    echo [INFO] Successfully archived data from $SRC to $DST
			exit 0
		else
			error_func 101
		fi
	;;
	-s|--sync)
		SRC=/mnt/archive/$VOLUME/$DRIVE1/
		DST=/mnt/archive/$VOLUME/$DRIVE2/
		echo [INFO] SharedData archive sync selected
	    echo [INFO] Syncing data from $SRC to $DST
		if rsync $SWITCHES $SRC $DST $EXCLUDE
		then
		    echo [INFO] Successfully synced data from $SRC to $DST
			exit 0
		else
			error_func 102
		fi
	;;
	*)
		error_func
	;;
esac

#!/bin/bash

# This script archives shared data from 's RAID array to a 2 disk HDD archive.

# General settings
SHAREDDATA=/mnt/data/shared
VOLUME=archive1
DRIVE1=drive1
DRIVE2=drive2

# Rsync settings
SWITCHES="-OvruEthm"                            # Rsync switches
EXCLUDE="--exclude=._* --exclude=.AppleDB*"     # Excluded files

# Error function definition
error_func() {
		case $1 in
		101)
		echo [ERROR] $0: Erorr code 101: Failed to archive data from $SHAREDDATA to /mnt/$VOLUME/$DRIVE1
		exit 101
		;;
		102)
		echo [ERROR] $0: Error code 102: Failed to archive data from /mnt/$VOLUME/$DRIVE1 to /mnt/$VOLUME/$DRIVE2
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
		SRC=$SHAREDDATA/
		DST=/mnt/$VOLUME/$DRIVE1/
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
		SRC=/mnt/$VOLUME/$DRIVE1/
		DST=/mnt/$VOLUME/$DRIVE2/
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

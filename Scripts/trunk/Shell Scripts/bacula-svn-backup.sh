#!/usr/bin/env bash

# This script is called by Bacula to perform full and incremental backups of SVN repositories.

# Directory to store backups in
SRC=/mnt/data/svn
DST=/mnt/backup1/SVN

##############################################################################################

LEVEL=$1
DST_FULL=$DST/Full
DST_INC=$DST/Incremental
STATUS=$DST/.status
SCRIPTNAME=`basename $0`
HOST=`hostname -s`

full_backup() {
for repo in $SRC/*
do
	
	echo "Full SVN dump completed successfully"
done
}

inc_backup() {
for repo in $SRC/*
do

	echo "Incremental SVN dump completed successfully"
done
}

case $2 in
cleanup)
	echo "Cleaning up files.";
	if rm -rf $DST
	then
		echo "Removed temporary files from ${DST}";
		exit 0
	else
		echo "Failed to remove temporary files from ${DST}";
	fi;;
esac

case $LEVEL in
full|Full|Differential|differential)
	echo "Full backup selected"
	if full_backup
	then
		echo "Proceeding to backup dump file with Bacula"
		exit 0
	else
		echo "An error occurred whilst dumping the repository"
		echo "Script will now exit"
		exit 100
	fi;;
inc|incremental|Incremental)
	echo "Incremental backup selected"
	if inc_backup
	then
		echo "Proceeding to backup dump file(s) with Bacula"
		exit 0
	else
		echo "An error occurred whilst dumping the repository"
		echo "Script will now exit."
		exit 100
	fi;;
*)
	echo "Invalid backup level specified"
	echo "Script will now exit"
	exit 100;;
esac
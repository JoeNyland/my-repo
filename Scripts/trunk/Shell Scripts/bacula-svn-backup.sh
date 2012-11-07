#!/usr/bin/env bash

# This script is called by Bacula to perform full and incremental backups of SVN repositories.

# Directory to store backups in
SRC=/mnt/data/svn
DST=/var/backups/svn

##############################################################################################

LEVEL=$1
DST_FULL=$DST/Full
DST_INC=$DST/Incremental
STATUS=$DST/.status
SCRIPTNAME=`basename $0`
HOST=`hostname -s`
DATE=`date +%Y%m%d`
TIME=`date +%H%M`
DATETIME=${DATE}${TIME}

if [ ! -d $DST ]
then
	mkdir $DST
fi

full_backup() {
# Create $DST folder structure:
mkdir $DST_FULL
for repo in $SRC/*
do
	# Get the last revision in the repo:
	LASTREV=`svnlook youngest $repo`
	echo $LASTREV > ${STATUS}_`basename $repo`
	# Perform a full dump of the repository:
	svnadmin dump -q $repo > $DST_FULL/`basename $repo`_${DATETIME}_full.svn.dmp
	echo "Full SVN dump of `basename $repo` completed successfully"
done
}

inc_backup() {
mkdir $DST_INC
for repo in $SRC/*
do
	LASTREV=`cat ${STATUS}_\`basename $repo\``
	CURREV=`svnlook youngest $repo`
	if [ $LASTREV -lt $CURREV ]
	then
		svnadmin dump -q --incremental -r $LASTREV:$CURREV > $DST_INC/`basename $repo`_${DATETIME}_inc.svn.dmp
		echo "Incremental SVN dump of `basename $repo` completed successfully"
	else
		echo "No changes have been comitted to `basename $repo` since the last full backup"
	fi
done
}

cleanup() {
echo "Cleaning up files";
if rm -rf $DST/*
then
	echo "Removed temporary files from ${DST}";
	exit 0
else
	echo "Failed to cleanup temporary files from ${DST}";
	return 1
fi
}

case $1 in
cleanup)
cleanup;;
esac

case $LEVEL in
full|Full|Differential|differential)
	echo "Full SVN backup selected"
	if full_backup
	then
		echo "Proceeding to backup dump file with Bacula"
		exit 0
	else
		echo "An error occurred whilst dumping the repositories"
		echo "Script will now exit"
		exit 100
	fi;;
inc|incremental|Incremental)
	echo "Incremental SVN backup selected"
	if inc_backup
	then
		echo "Proceeding to backup dump file(s) with Bacula"
		exit 0
	else
		echo "An error occurred whilst dumping the repositories"
		echo "Script will now exit"
		exit 100
	fi;;
*)
	echo "Invalid backup level specified"
	echo "Script will now exit"
	exit 100;;
esac
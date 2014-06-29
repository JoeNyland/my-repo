#!/bin/sh

# Directory containing SVN repositories:
SRC=/srv/svn

# Directory to store temporary backup files in:
DST=/var/backups/svn

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
	if svnadmin dump -q $repo > $DST_FULL/`basename $repo`_${DATETIME}_full.svn.dmp
	then
		echo "Full SVN dump of \"`basename $repo`\" completed successfully"
	fi
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
		if svnadmin dump -q --incremental -r $(( $LASTREV + 1 )):$CURREV $repo > $DST_INC/`basename $repo`_${DATETIME}_inc.svn.dmp
		then
			echo $CURREV > ${STATUS}_`basename $repo`
			echo "Incremental SVN dump of \"`basename $repo`\" completed successfully"
		fi
	else
		echo "No changes have been comitted to \"`basename $repo`\" since the last backup"
	fi
done
}

case $1 in
cleanup)
	echo "Cleaning up files"
	rm -rf $DST/* || { echo "Failed to cleanup temporary files from ${DST}"; exit 1; }
	echo "Removed temporary files from ${DST}"
	exit 0;;
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
		exit 100
	fi;;
*)
	echo "Invalid backup level specified"
	exit 100;;
esac

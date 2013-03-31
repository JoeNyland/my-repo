#!/bin/bash

if [ -z "$HOST" ]; then
	echo "Cannot determine system hostname.";
	exit 1001;
fi

# Destination backup file
DST=/tmp/$SCRIPTNAME_${HOST}_${DATE}_${TIME}.dmp.sql

# MySQL Binary logging configuration
MYSQLCONF=/etc/mysql/my.cnf
BINLOGDIR=/mnt/db/mysql/binlog
BINLOGPREFIX=mysql-bin
SCRIPTNAME=`basename $0`
HOST=`hostname -s`
HOME=`grep \`whoami\` /etc/passwd | awk -F":" '{print $6}'`
JOBID=$1
LEVEL=`echo $2 | awk '{print tolower($0)}'`
DATE=`date +%d-%m-%Y`
TIME=`date +%H-%M`

case $LEVEL in
full|differential)
	# FULL backup
	# Check that we can connect to MySQL.
	if echo 'show databases;' | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
	then
		echo "Performing full backup of MySQL databases from $HOST... "
			# Dump all databases.
			if mysqldump --defaults-extra-file=$HOME/.my.cnf --all-databases --master-data --delete-master-logs --flush-logs > ${DST}
				then
					echo "Completed full backup of MySQL databases from $HOST.";
					exit 0
				else
					echo "[ERROR]";
					echo "Full backup of MySQL databases from $HOST FAILED.";
					exit 1003;
				fi
	else
		echo "[ERROR]";
		echo "There seems to have been an error backing up the database(s).";
		echo "Please review the logged messages above.";
		exit 1004;
	fi;;
incremental)
	# INCREMENTAL backup
	echo "Incremental MySQL backup selected for ${HOST}";
	# If this returns 0, then binary logging appears to be enabled for MySQL, so incremental backup is possible.
	if grep "log_bin" ${MYSQLCONF} | egrep -v '^(#|$)' | grep "${BINLOGDIR}/${BINLOGPREFIX}" > /dev/null
	then
		# Check that we can connect to MySQL.
		if echo 'show databases;' | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
			then
				# Flushes the current logs, so that MySQL closes it's current file cleanly, then starts writing any new transactions to a new log file.
				echo "Flushing transaction logs for MySQL databases on ${HOST} to prepare for backup."
				mysqladmin --defaults-extra-file=$HOME/.my.cnf flush-logs;
				echo "MySQL binary transaction logs for databases on $HOST have been flushed and are ready to be backed up.";
				exit 0
			else
		echo "[ERROR]";
		echo "There seems to have been an error backing up the database(s).";
		echo "Please review the logged messages above.";
		exit 1007;
		fi;
	else
		echo "[ERROR]";
		echo "MySQL binary transaction logging does not appear to have been enabled in ${MYSQLCONF}.";
		echo "You must enable binary transaction logging in MySQL for incremental backups to work.";
		exit 1006;
	fi;;
cleanup)
	# Cleanup full backup file after backup.
	if [[ -f ${DST} ]]; then
		echo "Cleaning up files.";
		if rm -f $DST; then
			echo "Removed temporary file: ${DST}";
			exit 0;
		  else
		  echo "Failed to remove temporary file: ${DST}";
		  exit 1008;
		fi
	else
		exit 0;
	fi;;	
*)
	echo "[ERROR]";
	echo "You have not provided the required information to the script.";
	echo "Please use the following syntax:";
	echo "$SCRIPTNAME [JobID] [Level]";
	echo "Or:";
	echo "$SCRIPTNAME [JobID] cleanup";
	exit 1000;;
esac

echo "[ERROR]"
ehco "An undefined error occurred."
exit 1005

#!/bin/bash

# Directory to store backups in
DST=/mnt/db/mysql/.backups

# MySQL Binary logging configuration
MYSQLCONF=/etc/mysql/my.cnf
BINLOGDIR=/mnt/db/mysql/binlog
BINLOGPREFIX=mysql-bin

SCRIPTNAME=`basename $0`
HOST=`hostname -s`
HOME=`grep \`whoami\` /etc/passwd | awk -F":" '{print $6}'`

LEVEL=$1

DATE=`date +%d-%m-%Y`
TIME=`date +%H-%M`

if [[ "$2" == "cleanup" ]]; then
	if [[ -d ${DST} ]]; then
		echo "Cleaning up files.";
		if rm -rf $DST; then
			echo "Removed temporary files from ${DST}";
		  else
		  echo "Failed to remove temporary files from ${DST}";
		fi
	else
		echo "No files to be cleaned.";
	fi
	exit 0;
fi

if [ -z "$LEVEL" ]; then
	echo "[ERROR]";
	echo "You have not provided the required information to the script.";
	echo "Please use the following syntax: $SCRIPTNAME [Level]";
	echo "Or:";
	echo "$SCRIPTNAME [Level] cleanup";
	exit 1000;
fi

mkdir -p ${DST}

if [ -z "$HOST" ]; then
	echo "Cannot determine system hostname.";
	exit 1001;
fi

case $LEVEL in
Full|Differential)
	# FULL BACKUP (will also run the same backup for a differential level job.)
	# If the supplied credentials are vaild, then perform a FULL database dump to ${DST}/${HOST}_${db}.sql.bz2
	if echo 'show databases;' | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
	then
exit
		echo "Performing full backup of MySQL databases from $HOST... "
				if mysqldump --defaults-extra-file=$HOME/.my.cnf --all-databases --master-data --delete-master-logs --flush-logs > ${DST}/${HOST}_${DATE}_${TIME}.sql.dmp
				then
					echo "Completed full backup of MySQL databases from $HOST.";
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
Incremental)
	# INCREMENTAL BACKUP
	# If binary transaction logging is enabled in ${MYSQLCONF}, then the script will copy the transaction logs from ${BINLOGDIR} to ${DST}, ready to be backed up.
	echo "Incremental MySQL backup selected for ${HOST}";
	if grep "log_bin" ${MYSQLCONF} | egrep -v '^(#|$)' | grep "${BINLOGDIR}/${BINLOGPREFIX}" > /dev/null # If this returns 0, then binary logging appears to be enabled for MySQL.
	then
		if echo 'show databases;' | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
			then
				echo "Flushing transaction logs for MySQL databases on ${HOST} to prepare for backup."
				mysqladmin --defaults-extra-file=$HOME/.my.cnf flush-logs; # Flushes the current logs, so that MySQL closes it's current file cleanly, then starts writing any new transactions to a new log file.
				echo "MySQL binary transaction logs for databases on $HOST have been flushed and are ready to be backed up.";
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
*)
	echo "[ERROR]"
	echo "You have not specified the backup level variable in the client-run-before-job resource definition."
	echo "Please use the following syntax: $SCRIPTNAME [Level]";
	echo "Or:";
	echo "$SCRIPTNAME [Level] cleanup";
	exit 1005;;
esac

exit 0

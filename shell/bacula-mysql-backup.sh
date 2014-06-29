#!/bin/sh

MYSQLCONF=/etc/mysql/my.cnf
BINLOGDIR=/var/log/mysql
BINLOGPREFIX=mysql-bin

SCRIPTNAME=`basename $0`
HOST=`hostname -s`
HOME=`grep $(whoami) /etc/passwd | awk -F':' '{print $6}'`
JOBID=$1
LEVEL=`echo $2 | awk '{print tolower($0)}'`

# Destination backup file
DST=/tmp/`echo ${SCRIPTNAME} | awk -F'.' '{ print $1 }'`_${JOBID}_${HOST}.dmp.sql

case $LEVEL in
full|differential)
	# FULL backup
	# Check that we can connect to MySQL.
	if echo "show databases;" | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
	then
		echo "Performing full backup of MySQL databases from $HOST... "
			# Dump all databases.
			if mysqldump --defaults-extra-file=$HOME/.my.cnf --all-databases --master-data --delete-master-logs --flush-logs > ${DST}
				then
					echo "Completed full backup of MySQL databases from $HOST.";
					exit 0
				else
					exit 1003;
					echo "[ERROR] Full backup of MySQL databases from $HOST FAILED.";
				fi
	else
		exit 1004;
		echo "[ERROR] There seems to have been an error backing up the database(s).";
	fi;;
incremental)
	# INCREMENTAL backup
	echo "Incremental MySQL backup selected for ${HOST}";
	# If this returns 0, then binary logging appears to be enabled for MySQL, so incremental backup is possible.
	if grep 'log_bin' ${MYSQLCONF} | egrep -v '^(#|$)' | grep "${BINLOGDIR}/${BINLOGPREFIX}" > /dev/null
	then
		# Check that we can connect to MySQL.
		if echo "show databases;" | mysql --defaults-extra-file=$HOME/.my.cnf -s >/dev/null
			then
				# Flushes the current logs, so that MySQL closes it's current file cleanly, then starts writing any new transactions to a new log file.
				echo "Flushing transaction logs for MySQL databases on ${HOST} to prepare for backup."
				mysqladmin --defaults-extra-file=$HOME/.my.cnf flush-logs;
				echo "MySQL binary transaction logs for databases on $HOST have been flushed and are ready to be backed up.";
				exit 0
			else
		exit 1007;
		echo "[ERROR] There seems to have been an error backing up the database(s).";
		fi;
	else
		exit 1006;
		echo "[ERROR] MySQL binary transaction logging does not appear to have been enabled in ${MYSQLCONF}. You must enable binary transaction logging in MySQL for incremental backups to work.";
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
	exit 1000;;
	echo "[ERROR] You have not provided the required information to the script.";
esac


#!/bin/bash

# Directory to store backups in
DST=/var/backups/mysql

# MySQL Binary logging configuration
MYSQLCONF=/etc/mysql/my.cnf
BINLOGDIR=/var/log/mysql
BINLOGPREFIX=mysql-bin

# A regex, passed to egrep -v, for which databases to ignore
#IGNREG='^snort$'
IGNREG='information_schema'

SCRIPTNAME=`basename $0`
HOST=`hostname -s`

LEVEL=$1
DBUSER=$2
DBPASS=$3

if [[ "$4" == "cleanup" ]]; then
	if [[ -d ${DST} ]]; then
		echo "Cleaning up files.";
		if rm -rf $DST; then
			echo "Removed temporary files from ${DST}";
			if [[ "$LEVEL" == "Full" ]]; then
				echo "Performed a full backup of the databases on ${HOST}, so we can truncate the transaction logs.";
				if echo "RESET MASTER" | mysql -u ${DBUSER} -p${DBPASS}
					then
						echo "Successfully truncated the transaction logs.";
					else
						echo "[WARNING]";
						echo "FAILED to truncate transaction log files from ${BINLOGDIR}";
						echo "As this is not a fatal error, the backup will proceed";
				fi
			fi
		fi
	else
		echo "No files to be cleaned.";
	fi
	exit 0;
fi

if [ -z "$DBUSER" -o -z "$DBPASS" ]; then
	echo "[ERROR]";
	echo "You have not provided the required information to the script.";
	echo "Please use the following syntax: $SCRIPTNAME [Level] [MySQL_User] [MySQL_Password]";
	echo "Or:";
	echo "$SCRIPTNAME [Level] [MySQL_User] [MySQL_Password] cleanup";
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
	if echo 'show databases;' | mysql -s -u ${DBUSER} -p${DBPASS} >/dev/null
	then
		for db in $(echo 'show databases;' | mysql -s -u ${DBUSER} -p${DBPASS} | egrep -v ${IGNREG}) ; do
				echo "Performing full backup of MySQL database ${db} from $HOST... "
				if mysqldump --single-transaction --opt -u ${DBUSER} -p${DBPASS} ${db} > ${DST}/${HOST}_${db}.sql.dmp
				then
					echo "Completed full backup of MySQL database ${db} from $HOST.";
				else
					echo "[ERROR]";
					echo "Full backup of MySQL database ${db} from $HOST FAILED.";
					exit 1003;
				fi
		done
		mysqladmin flush-logs -u ${DBUSER} -p${DBPASS}; # Flushes the current logs, so that MySQL closes it's current file cleanly, then starts writing any new transactions to a new log file.
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
		echo "Flushing transaction logs for MySQL databases on ${HOST} to prepare for backup."
		mysqladmin flush-logs -u ${DBUSER} -p${DBPASS}; # Flushes the current logs, so that MySQL closes it's current file cleanly, then starts writing any new transactions to a new log file.
		echo "MySQL binary transaction logs for databases on $HOST have been flushed and are ready to be backed up.";
	else
		echo "[ERROR]";
		echo "MySQL binary transaction logging does not appear to have been enabled in ${MYSQLCONF}.";
		echo "You must enable binary transaction logging in MySQL for incremental backups to work.";
		exit 1006;
	fi;;
*)
	echo "[ERROR]"
	echo "You have not specified the backup level variable in the client-run-before-job resource definition."
	echo "Please use the following syntax: $SCRIPTNAME [Level] [MySQL_User] [MySQL_Password]";
	echo "Or:";
	echo "$SCRIPTNAME [Level] [MySQL_User] [MySQL_Password] cleanup";
	exit 1005;;
esac

exit 0
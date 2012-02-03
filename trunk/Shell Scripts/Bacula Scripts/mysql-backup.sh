#!/bin/bash

# Directory to store backups in
DST=/var/backups/mysql

# A regex, passed to egrep -v, for which databases to ignore
#IGNREG='^snort$'
IGNREG='information_schema'

SCRIPTNAME=`basename $0`
HOST=`hostname -s`

if [[ "$1" == "cleanup" ]]; then
	if [[ -d ${DST} ]]; then
		echo "Cleaning up files.";
		if rm -rf $DST; then
			echo "Removed temporary files from ${DST}";
		fi
	else
		echo "No files to be cleaned.";
	fi
	exit 0;
fi

DBUSER=$1
DBPASS=$2

if [ -z "$DBUSER" -o -z "$DBPASS" ]; then
	echo "[ERROR]";
	echo "You have not provided the required information to the script.";
	echo "Please use the following syntax: $SCRIPTNAME [MySQL_User] [MySQL_Password]";
	echo "Or:";
	echo "$SCRIPTNAME cleanup";
	exit 1000;
fi

mkdir -p ${DST}

if [ -z "$HOST" ]; then
	echo "Cannot determine system hostname.";
	exit 1001;
fi

if echo 'show databases;' | mysql -s -u ${DBUSER} -p${DBPASS} >/dev/null
then
	for db in $(echo 'show databases;' | mysql -s -u ${DBUSER} -p${DBPASS} | egrep -v ${IGNREG}) ; do
			echo "Backing up MySQL database ${db} from $HOST... "
			if mysqldump --opt -u ${DBUSER} -p${DBPASS} ${db} | bzip2 -c > ${DST}/${HOST}_${db}.sql.bz2
			then
				echo "Completed backup of MySQL database ${db} from $HOST.";
			else
				echo "[ERROR]";
				echo "Backup of MySQL database ${db} from $HOST FAILED.";
				exit 1003;
			fi
	done
else
	echo "[ERROR]";
	echo "There seems to have been an error dumping the database(s).";
	echo "Please review the logged messages above.";
	exit 1004;
fi

exit 0
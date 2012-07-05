#!/bin/bash
# Script to sync files from RAID array on /mnt/array to USB backup HDD on /mnt/backup.

# General settings
ARRAY=/mnt/array															# Where the RAID array is mounted.
BACKUPDRIVE=/mnt/backup2													# Where the USB backup HDD is mounted.

# Email settings
SMTPSERVER=mail											# SMTP server address.
SMTPUSER=																	# SMTP username.
SMTPPASS=																	# SMTP password.
FROM=`hostname -s`@`hostname -d`											# From address for emails.
TO=												# To address for emails.

############################################################################################################

# MythTV overrides
OVER="--exclude='livetv/*'"													# MythTV specific overrides to Rsync (e.g. excluded directories).

# Rsync settings
STDSWITCHES="-vruEthm --delete"												# Standard Rsync switches.
STDEXCLUDE="--exclude='._*' --exclude='.AppleDB*' --exclude='lost+found' "	# Standard excluded files.

# Logger settings
STDLOGGER="-sp cron.info"													# Standard logger switches

############################################################################################################

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1000
fi

if [ ! -z "$1" ]; then 
	SRCDIR=$1
else
	echo "You have not provided the name of the directory that you would like to sync.";
	echo ;
	echo "Correct syntax is:";
	echo "`hostname -s`:-$ ./array-backup.sh <directory name to sync>";
	exit 1000;
fi
SRC=$ARRAY/`echo $SRCDIR | sed -e 's/\(.*\)/\L\1/'`
DSTDIR=$SRCDIR
DST=$BACKUPDRIVE/$DSTDIR
LOGGERTAG=" -t $SRCDIR-backup"

rsync $STDSWITCHES $SRC/ $DST/ $STDEXCLUDE $OVER | logger $STDLOGGER $LOGGERTAG

if [ $PIPESTATUS = 0 ]; then
sendemail -f $FROM -t $TO -s $SMTPSERVER -o username=$SMTPUSER -o password=$SMTPPASS -u "$SRCDIR backup successful on `hostname -f`" <<EOFBODY
<HTML>
	<HEAD>
		<style type="text/css">
			*{font-family:"Lucida Grande",Verdana;}
			h3.success{color:rgb(151,192,5);}
			.terminal{font-family:"Courier";
			background-color:rgb(0,0,0);
			color:rgb(255,255,255);}
		</style>
	</HEAD>
	
	<BODY>
		<h3 class="success">$SRCDIR Backup Successful</h3>
		
		<p>The Rsync cron job to synchronise $SRCDIR files from your RAID array to your USB backup HDD completed successfully.</p>
		<p>The following directories were synchronised:</br>
		`echo $SRC` --> `echo $DST`</br>
		</p>
		
		<p>If you require more information on the backup, please run the following command from :</p>
		<div class="terminal">grep $SRCDIR-backup /var/log/syslog | tail --lines=100</div>
	</BODY>
</HTML>
EOFBODY
else
sendemail -f $FROM -t $TO -s $SMTPSERVER -o username=$SMTPUSER -o password=$SMTPPASS -u "$SRCDIR backup FAILURE for `hostname -f`" <<EOFBODY
<HTML>
	<HEAD>
		<style type="text/css">
			*{font-family:"Lucida Grande",Verdana;}
			h3.fail{color:rgb(228,32,11);}
			.terminal{font-family:"Courier";
			background-color:rgb(0,0,0);
			color:rgb(255,255,255);}
		</style>
	</HEAD>
	
	<BODY>
		<h3 class="fail">$SRCDIR Backup FAILURE</h3>
		
		<p>The Rsync cron job to synchronise $SRCDIR files from your RAID array to your USB backup HDD failed with one or more errors.</p>
		
		<p>If you require more information on the backup, please run the following command from :</p>
		<div class="terminal">grep $SRCDIR-backup /var/log/syslog | tail --lines=100</div>		
	</BODY>
</HTML>
EOFBODY
fi
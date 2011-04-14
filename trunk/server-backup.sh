#!/bin/bash
# Server Backup Script

SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
SUCCESSSUBJECT="Server backup success for "
FAILURESUBJECT="Server backup failure for "
FROMADDRESS=
TOADDRESS=

cd /mnt/usb_backup/Backups/Server || exit
tar cvpjf $HOSTNAME-`date +%F`.tar.bz2 --exclude=/tmp --exclude=/proc --exclude=/lost+found --exclude=/cdrom --exclude=/media --exclude=/mnt --exclude=/sys --exclude=/dev / > server-backup.log


if [ -f /mnt/usb_backup/Backups/Server/$HOSTNAME-`date +%F`.tar.bz2 ]; then
	echo "The full backup of the server completed successfully. See below for the listing of the backup directory to see the files." > /tmp/server-backup-report.log
	echo "" >> /tmp/server-backup-report.log
	ls -lah /mnt/usb_backup/Backups/Server | grep -i "$HOSTNAME-`date +%F`.tar.bz2" >> /tmp/server-backup-report.log
	sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $SUCCESSSUBJECT < /tmp/server-backup-report.log
else
	echo "The full backup of the server failed last night. Please review the backup log file below, for more information..." > /tmp/server-backup-report.log
	echo "" >> /tmp/server-backup-report.log
	tail /mnt/usb_backup/Backups/Server/server-backup.log >> /tmp/server-backup-report.log
	sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $FAILURESUBJECT < /tmp/server-backup-report.log
fi

chown : /mnt/usb_backup/Backups/Server/*

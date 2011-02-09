#!/bin/bash
# Server Backup Script

cd /mnt/usb_backup/Backups/Server || exit
tar cvpjf $HOSTNAME-`date +%F`.tar.bz2 --exclude=/tmp --exclude=/proc --exclude=/lost+found --exclude=/cdrom --exclude=/media --exclude=/mnt --exclude=/sys --exclude=/dev / > server-backup.log


if [ -f /mnt/usb_backup/Backups/Server/$HOSTNAME-`date +%F`.tar.bz2 ]; then
        echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	echo "The full backup of the server completed successfully. See below for the listing of the backup directory to see the files." >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	ls -lah /mnt/usb_backup/Backups/Server | grep -i "$HOSTNAME-`date +%F`.tar.bz2" >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
else
        echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	echo "The full backup of the server failed last night. Please review the backup log file below, for more information..." >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	tail /mnt/usb_backup/Backups/Server/server-backup.log >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
        echo "" >> /var/log/overnight-jobs.log
fi

chown : /mnt/usb_backup/Backups/Server/*
chown : /var/log/overnight-jobs.log

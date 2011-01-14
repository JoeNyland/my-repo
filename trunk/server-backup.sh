#!/bin/bash
# Server Backup Script

cd /mnt/usb_backup/Backups/Server || exit
tar cvpjf $HOSTNAME-`date +%F`.tar.bz2 --exclude=/tmp --exclude=/proc --exclude=/lost+found --exclude=/cdrom --exclude=/media --exclude=/mnt --exclude=/sys --exclude=/dev / > server-backup.log || rm -rfv /mnt/usb_backup/Backups/Server/$HOSTNAME-`date +%F`.tar.bz2

if [ -f /mnt/usb_backup/Backups/Server/$HOSTNAME-`date +%F`.tar.bz2 ]; then
	echo "The full backup of the server completed successfully. See below for the listing of the backup directory to see the files." >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	ls -lah /mnt/usb_backup/Backups/Server | grep -i "$HOSTNAME-`date +%F`.tar.bz2" >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
else
	echo "The full backup of the server failed last night. Please review the backup log file below, for more information..." >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	tail /mnt/usb_backup/Backups/Server/server-backup.log >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
        echo "" >> /tmp/overnight-jobs.log
fi

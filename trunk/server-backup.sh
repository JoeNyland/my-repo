#!/bin/bash
# Server Backup Script

cd /mnt/usb_backup/Backups/Server || exit
tar cvpjf $HOSTNAME-`date +%F`.tar.bz2 --exclude=/proc --exclude=/lost+found --exclude=/cdrom --exclude=/media --exclude=/mnt --exclude=/sys --exclude=/dev / > server-backup.log


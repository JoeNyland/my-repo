#!/bin/bash
# Backup Script

echo
echo Welcome to the MasterRoot script to backup your PC to a backup file.
echo
echo This script will backup your filesystem to the "Backup" share on 
echo (), which it will try to mount under /backup.
echo 
echo If this share is inaccessible or not available, please press Ctrl + C to exit this
echo script and retry when this share is available.
echo
echo -n Press return to continue.
read ans
clear
gksudo su || sudo su
cd /backup || mkdir /backup
cd /backup
smbmount ///Backups /backup -o username=,password=,rw || echo Backup location is not available. Press CTRL + C to exit now.
cd ./$HOSTNAME || mkdir ./$HOSTNAME
cd ./$HOSTNAME
echo -n Press return if you would like to proceed to backup your system to /backup.
read ans
tar cvpjf $HOSTNAME.tar.bz2 --exclude=/proc --exclude=/lost+found --exclude=/media --exclude=/mnt --exclude=/sys --exclude=/dev / > /var/log/backup.log / > /var/log/backup.log
cp /var/log/backup.log /backup/Backup.log
clear
echo Backup file $HOSTNAME.tar.bz2 created successfully.
echo
echo A log of this backup task has been saved to /var/log/backup.log
echo 
echo A copy of this log has also been copied to the backup location.
echo
nautilus /backup/
echo -n Press return if you are happy with the backed up file and wish to exit.
read ans
exit
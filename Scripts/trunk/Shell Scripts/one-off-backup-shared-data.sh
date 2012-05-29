#!/bin/bash

# Script to duplicate backups of shared data from  to 's iMac.
# Created 15/01/2012

SHARED_DIR=/mnt/array/Shared
SVN=/mnt/array/svn
MAC_BACKUP=/mnt/mac_backup
MAC_MINI_BACKUP=/mnt/mac-mini_backup
_BACKUP=/mnt/_backup
BACKUPDRIVE=/mnt/mac_backup
SERVERBACKUPDRIVE=/mnt/usb_backup
SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
FROMADDRESS=
TOADDRESS=
LOGFILE=/var/log/shared-backup-to-imac.log
NOTIFICATIONLOG=/tmp/shared-backup-to-imac-report.log

mkdir -p {$MAC_BACKUP/Shared/"TV Shows",$MAC_BACKUP/Shared/"Movies",$_BACKUP/Shared/Movies/"Blu Ray Movies",$MAC_MINI_BACKUP/Shared/"Applications and Tools",$MAC_MINI_BACKUP/Shared/"Disc Images",$MAC_MINI_BACKUP/Shared/"Games",$SHARED_DIR/"Music",$MAC_BACKUP/SVN/}

# TV Shows to iMac
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/"TV Shows" $MAC_BACKUP/Shared/"TV Shows" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit

# Movies to iMac (without BluRays)
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/Movies $MAC_BACKUP/Shared/"Movies" --exclude="Blu Ray Movies" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit

# BluRays to 
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/Movies/"Blu Ray Movies" $_BACKUP/Shared/Movies/"Blu Ray Movies" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit

# Mac mini will take: Apps, Disc Images, Games, Music
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/"Applications and Tools" $MAC_MINI_BACKUP/Shared/"Applications and Tools" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/"Disc Images" $MAC_MINI_BACKUP/Shared/"Disc Images" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/"Games" $MAC_MINI_BACKUP/Shared/"Games" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit
rsync -vruEthm --log-file=$LOGFILE $SHARED_DIR/"Music" $MAC_MINI_BACKUP/Shared/"Music" --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit

# SVN to iMac
rsync -vruEthm --log-file=$LOGFILE $SVN/ $MAC_BACKUP/SVN/ --exclude="._*" --exclude=".AppleDB*" || exit

echo "The Rsync job to synchronise files from your RAID array to your iMac completed successfully." > $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "If you require more information, please run the following command:" >> $NOTIFICATIONLOG
echo "cat /var/log/shared-backup.log" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG

sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "Shared files backup success to iMac" < $NOTIFICATIONLOG
#!/bin/bash

# Script to duplicate backups of shared data from  to 's iMac.
# Created 15/01/2012

SHARED_DIR=/mnt/array/Shared
SVN=/mnt/array/svn
MAC_BACKUP=/mnt/mac_backup
_BACKUP=/mnt/_backup
BACKUPDRIVE=/mnt/mac_backup
SERVERBACKUPDRIVE=/mnt/usb_backup
SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
FROMADDRESS=
TOADDRESS=
LOGFILE=/var/log/shared-backup.log
NOTIFICATIONLOG=/tmp/shared-backup-report.log

rsync -vruEthm --dry-run --delete --log-file=$LOGFILE $SHARED_DIR/ $BACKUPDRIVE/Shared/ --exclude="._*" --exclude="Downloads/" --exclude=".AppleDB*" --exclude="lost+found" || exit
mkdir $BACKUPDRIVE/Shared/Downloads
rsync -vruEthm --dry-run --delete --log-file=$LOGFILE $SVN/ $BACKUPDRIVE/SVN/ --exclude="._*" --exclude=".AppleDB*" || exit

echo "The Rsync job to synchronise files from your RAID array to your iMac completed successfully." > $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "If you require more information, please run the following command:" >> $NOTIFICATIONLOG
echo "cat /var/log/shared-backup.log" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG
echo "" >> $NOTIFICATIONLOG

sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "Shared files backup success to iMac" < $NOTIFICATIONLOG
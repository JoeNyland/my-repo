#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/array/Shared
MAC_BACKUP=/mnt/mac_backup
_BACKUP=/mnt/_backup
BACKUPDRIVE=/mnt/backup
SERVERBACKUPDRIVE=/mnt/usb_backup
SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
FROMADDRESS=
TOADDRESS=

#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/TV\ Shows $MAC_BACKUP/Shared --exclude="._*" || exit
#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies $MAC_BACKUP/Shared/ --exclude="Blu Ray Movies" --exclude="._*" || exit
#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Applications $_BACKUP/ --exclude="._*" --exclude="apt-mirror" || exit
#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Disc\ Images $_BACKUP/ --exclude="._*" || exit
#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Music $_BACKUP/ --exclude="._*" || exit
#rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies/Blu\ Ray\ Movies $_BACKUP/ --exclude="._*" || exit
rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/ $BACKUPDRIVE/Shared/ --exclude="._*" --exclude="Downloads/" --exclude=".AppleDB*" --exclude="lost+found" --exclude="apt-mirror" || exit

echo "The Rsync job to synchronise the following items completed successfully last night." > /tmp/shared-backup-report.log
#echo "/mnt/shared/TV Shows --> \\s-iMac\Backups\Shared\TV Shows" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Movies --> \\s-iMac\Backups\Shared\Movies" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Applications --> \\\Backups\Applications" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Disc Images --> \\\Backups\Disc Images" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Music --> \\\Backups\Music" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Movies/Blu Ray Movies --> \\\Backups\Blu Ray Movies" >> /tmp/shared-backup-report.log
echo "/mnt/shared --> Backup Drive" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "If you require more information, please run the following command:" >> /tmp/shared-backup-report.log
echo "cat /var/log/shared-backup.log" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log

sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "Shared files backup success for " < /tmp/shared-backup-report.log

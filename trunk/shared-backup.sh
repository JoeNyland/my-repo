#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/array/Shared
TIMEMACHINE_DIR=/mnt/array/TimeMachine
SVN=/mnt/array/svn
MYTHTV=/mnt/array/mythtv
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
rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/ $BACKUPDRIVE/Shared/ --exclude="._*" --exclude="Downloads/" --exclude=".AppleDB*" --exclude="lost+found" || exit
rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $TIMEMACHINE_DIR/ $BACKUPDRIVE/TimeMachine/ --exclude="._*" --exclude=".AppleDB*" --exclude="lost+found" || exit
rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $SVN/ $BACKUPDRIVE/SVN/ --exclude="._*" --exclude=".AppleDB*" || exit
rsync -vruEthm --progress --log-file=/var/log/shared-backup.log $MYTHTV/ $BACKUPDRIVE/MythTV/ --exclude="._*" --exclude=".AppleDB*" --exclude="livetv/*"|| exit

echo "The Rsync job to synchronise the following items completed successfully last night." > /tmp/shared-backup-report.log
#echo "/mnt/shared/TV Shows --> \\s-iMac\Backups\Shared\TV Shows" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Movies --> \\s-iMac\Backups\Shared\Movies" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Applications --> \\\Backups\Applications" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Disc Images --> \\\Backups\Disc Images" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Music --> \\\Backups\Music" >> /tmp/shared-backup-report.log
#echo "/mnt/shared/Movies/Blu Ray Movies --> \\\Backups\Blu Ray Movies" >> /tmp/shared-backup-report.log
echo "/mnt/array/Shared --> Backup Drive" >> /tmp/shared-backup-report.log
echo "/mnt/array/svn --> Backup Drive" >> /tmp/shared-backup-report.log
echo "/mnt/array/TimeMachine --> Backup Drive" >> /tmp/shared-backup-report.log
echo "/mnt/array/mythtv --> Backup Drive" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "If you require more information, please view the following file:" >> /tmp/shared-backup-report.log
echo "/var/log/shared-backup.log" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log
echo "" >> /tmp/shared-backup-report.log

sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "Shared files backup success for " < /tmp/shared-backup-report.log

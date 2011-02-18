#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/shared
MAC_BACKUP=/mnt/mac_backup
_BACKUP=/mnt/_backup
BACKUPDRIVE=/mnt/backup
SERVERBACKUPDRIVE=/mnt/usb_backup

rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/TV\ Shows $MAC_BACKUP/Shared --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies $MAC_BACKUP/Shared/ --exclude="Blu Ray Movies" --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Applications $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Disc\ Images $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Music $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies/Blu\ Ray\ Movies $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SERVERBACKUPDRIVE/Backups/ $BACKUPDRIVE/Server\ Backups/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/ $BACKUPDRIVE/Shared/ --exclude="._*"

echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
echo "" >> /var/log/overnight-jobs.log
echo "The Rsync job to synchronise the following items completed successfully last night." >> /var/log/overnight-jobs.log
echo "/mnt/shared/TV Shows --> \\s-iMac\Backups\Shared\TV Shows" >> /var/log/overnight-jobs.log
echo "/mnt/shared/Movies --> \\s-iMac\Backups\Shared\Movies" >> /var/log/overnight-jobs.log
echo "/mnt/shared/Applications --> \\\Backups\Blu Ray Movies" >> /var/log/overnight-jobs.log
echo "/mnt/shared/Disc Images --> \\\Backups\Blu Ray Movies" >> /var/log/overnight-jobs.log
echo "/mnt/shared/Music --> \\\Backups\Blu Ray Movies" >> /var/log/overnight-jobs.log
echo "/mnt/shared/Movies/Blu Ray Movies --> \\\Backups\Blu Ray Movies" >> /var/log/overnight-jobs.log
echo "/mnt/shared --> Backup Drive" >> /var/log/overnight-jobs.log
echo "/mnt/usb_backup/Backups --> Backup Drive" >> /var/log/overnight-jobs.log
echo "" >> /var/log/overnight-jobs.log
echo "If you require more information, please run the following command:" >> /var/log/overnight-jobs.log
echo "cat /var/log/shared-backup.log" >> /var/log/overnight-jobs.log
echo "" >> /var/log/overnight-jobs.log
echo "" >> /var/log/overnight-jobs.log
echo "" >> /var/log/overnight-jobs.log

#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/shared
MAC_BACKUP=/mnt/mac_backup
_BACKUP=/mnt/_backup

rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/TV\ Shows $MAC_BACKUP/Shared --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies $MAC_BACKUP/Shared/ --exclude="Blu Ray Movies" --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Applications $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Disc\ Images $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Music $_BACKUP/ --exclude="._*" || exit
rsync -vruEthim --progress --log-file=/var/log/shared-backup.log $SHARED_DIR/Movies/Blu\ Ray\ Movies $_BACKUP/ --exclude="._*" || exit
echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
echo "" >> /tmp/overnight-jobs.log
echo "The Rsync job to synchronise the following items completed successfully last night." >> /tmp/overnight-jobs.log
echo "/mnt/shared/TV Shows > \\s-iMac\Backups\Shared\TV Shows" >> /tmp/overnight-jobs.log
echo "/mnt/shared/Movies > \\s-iMac\Backups\Shared\Movies" >> /tmp/overnight-jobs.log
echo "/mnt/shared/Applications > \\\Backups\Blu Ray Movies" >> /tmp/overnight-jobs.log
echo "/mnt/shared/Disc Images > \\\Backups\Blu Ray Movies" >> /tmp/overnight-jobs.log
echo "/mnt/shared/Music > \\\Backups\Blu Ray Movies" >> /tmp/overnight-jobs.log
echo "/mnt/shared/Movies/Blu Ray Movies > \\\Backups\Blu Ray Movies" >> /tmp/overnight-jobs.log
echo "" >> /tmp/overnight-jobs.log
echo "If you require more information, please run the following command:" >> /tmp/overnight-jobs.log
echo "cat /var/log/shared-backup.log" >> /tmp/overnight-jobs.log
echo "" >> /tmp/overnight-jobs.log
echo "" >> /tmp/overnight-jobs.log
echo "" >> /tmp/overnight-jobs.log

#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/shared
MAC_BACKUP=/mnt/mac_backup
_BACKUP=/mnt/_backup

rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/TV\ Shows $MAC_BACKUP/Shared
rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/Movies $MAC_BACKUP/Shared/ --exclude="Blu Ray Movies"
#rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/Applications $_BACKUP/
#rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/Disc\ Images $_BACKUP/
#rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/Music $_BACKUP/
#rsync -vruEthim --progress --log-file=$HOME/.shared-backup.log $SHARED_DIR/Movies/Blu\ Ray\ Movies/ $_BACKUP/

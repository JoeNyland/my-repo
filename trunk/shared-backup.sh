#!/bin/bash
# Shared files backup script to backup files from /mnt/server to 's iMac

SHARED_DIR=/mnt/shared
MAC_BACKUP=/mnt/mac-backup
_BACKUP=/mnt/-backup

rsync -vruEthim --progress --log-file=$SHARED_DIR/.shared-backup.log $SHARED_DIR/TV\ Shows $MAC_BACKUP/Server/
rsync -vruEthim --progress --log-file=$SHARED_DIR/.shared-backup.log $SHARED_DIR/Movies $MAC_BACKUP/Server/
rsync -vruEthim --progress --log-file=$SHARED_DIR/.shared-backup.log $SHARED_DIR/Applications $_BACKUP/
rsync -vruEthim --progress --log-file=$SHARED_DIR/.shared-backup.log $SHARED_DIR/Disc\ Images $_BACKUP/
rsync -vruEthim --progress --log-file=$SHARED_DIR/.shared-backup.log $SHARED_DIR/Music $_BACKUP/

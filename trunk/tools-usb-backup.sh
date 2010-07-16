#!/bin/bash
# Tools USB Drive Backup Script
TEMPLOCATION="/tmp/tools-backup"

mkdir $TEMPLOCATION
cp -rfv /mnt/tools/* $TEMPLOCATION
cd /mnt	/usb_backup/Tools
tar cvpjf "Tools USB Drive"-`date +%F`.tar.bz2 $TEMPLOCATION/* > tools-usb-backup.log
rm -rfv $TEMPLOCATION
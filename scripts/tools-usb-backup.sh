#!/bin/bash
# Tools USB Drive Backup Script

cd /mnt/usb_backup/Backups/Tools\ USB\ Drive/ || exit
tar cvpjf "Tools USB Drive"-`date +%F`.tar.bz2 /mnt/tools > tools-usb-backup.log


#!/bin/bash
# Tools USB Drive Backup Script

cd /mnt/usb_backup/Backups/Tools || exit
tar cvpjf "Tools USB Drive"-`date +%F`.tar.bz2 /mnt/tools > tools-usb-backup.log || exit

if [ -f /mnt/usb_backup/Backups/Email/MobileMe/Backup_Logs-`date +%F`.tar.bz2 ]; then
                echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "The backup of your tools USB drive completed successfully last night." >> /tmp/overnight-jobs.log
                echo "Please see below for the file name..." >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                ls -lah /mnt/usb_backup/Backups/Tools/"Tools USB Drive"-`date +%F`.tar.bz2 >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
        else
                echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "The backup of your tools USB drive failed to run last night. Please verify the tar backup log below..." >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                tail /mnt/usb_backup/Backups/Tools/tools-usb-backup.log
                echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
fi


#!/bin/bash
# Subversion Repository Backup Script

cd /mnt/usb_backup/Backups/SVN || exit
tar cvpjf "SVN-Repositories-`date +%F`.tar.bz2" /mnt/shared/SVN > svn-backup.log

if [ -f /mnt/usb_backup/Backups/SVN/"SVN-Repositories-`date +%F`.tar.bz2" ]; then
                echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "The backup of your SVN repositories completed successfully last night." >> /var/log/overnight-jobs.log
                echo "Please see below for the file name..." >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                ls -lah /mnt/usb_backup/Backups/SVN/"SVN-Repositories-`date +%F`.tar.bz2" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
        else
                echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "The backup of your SVN repositories failed to run last night. Please verify the tar backup log below..." >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                tail /mnt/usb_backup/Backups/SVN/svn-backup.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
fi


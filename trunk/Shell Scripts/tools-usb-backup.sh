#!/bin/bash
# Tools USB Drive Backup Script

SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
SUCCESSSUBJECT="Tools USB drive backup success for "
FAILURESUBJECT="Tools USB drive backup failure for "
FROMADDRESS=
TOADDRESS=


cd /mnt/usb_backup/Backups/Tools || exit
tar cvpjf "Tools USB Drive"-`date +%F`.tar.bz2 /mnt/tools > tools-usb-backup.log

if [ -f /mnt/usb_backup/Backups/Email/MobileMe/Backup_Logs-`date +%F`.tar.bz2 ]; then
                echo "The backup of your tools USB drive completed successfully last night." > /var/log/overnight-jobs.log
                echo "Please see below for the file name..." >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                ls -lah /mnt/usb_backup/Backups/Tools/"Tools USB Drive"-`date +%F`.tar.bz2 >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $SUCCESSSUBJECT < /tmp/tools-backup-report.log
        else
                echo "The backup of your tools USB drive failed to run last night. Please verify the tar backup log below..." > /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                tail /mnt/usb_backup/Backups/Tools/tools-usb-backup.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $FAILURESUBJECT < /tmp/tools-backup-report.log		
fi


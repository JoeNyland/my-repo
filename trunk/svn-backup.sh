#!/bin/bash
# Subversion Repository Backup Script

cd /mnt/usb_backup/Backups/SVN || exit
tar cvpjf "SVN-Repositories-`date +%F`.tar.bz2" /mnt/shared/SVN > svn-backup.log

SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
SUCCESSSUBJECT="SVN backup success for "
FAILURESUBJECT="SVN backup failure for "
FROMADDRESS=
TOADDRESS=

if [ -f /mnt/usb_backup/Backups/SVN/"SVN-Repositories-`date +%F`.tar.bz2" ]; then
                echo "The backup of your SVN repositories completed successfully last night." > /tmp/svn-backup-report.log
                echo "Please see below for the file name..." >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
                ls -lah /mnt/usb_backup/Backups/SVN/"SVN-Repositories-`date +%F`.tar.bz2" >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
	sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $SUCCESSSUBJECT < /tmp/svn-backup-report.log
        else
                echo "The backup of your SVN repositories failed to run last night. Please verify the tar backup log below..." > /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
                tail /mnt/usb_backup/Backups/SVN/svn-backup.log
                echo "" >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
                echo "" >> /tmp/svn-backup-report.log
	sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $SUCCESSSUBJECT < /tmp/svn-backup-report.log
fi


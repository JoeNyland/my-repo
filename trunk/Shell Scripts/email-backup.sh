#!/bin/bash

SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
FROMADDRESS=
TOADDRESS=

# Remove previous backup log files
rm -v /var/log/email-backup/iCloud_Archive.log
rm -v /var/log/email-backup/iCloud_Deleted_Messages.log
rm -v /var/log/email-backup/iCloud_Sent_Messages.log

# Create directories/files
[ ! -d /tmp/email-backup/iCloud ] && mkdir -p /tmp/email-backup/iCloud
[ ! -d /mnt/backup/Email/iCloud ] && mkdir -p /mnt/backup/Email/iCloud

touch /tmp/email-backup/iCloud/Archive.mbox
touch /tmp/email-backup/iCloud/Deleted_Messages.mbox
touch /tmp/email-backup/iCloud/Sent_Messages.mbox

# Backup iCloud mailboxes, tar and remove source files.
getmail --getmaildir=/home//.getmail -r icloud_Archive || exit 1000
getmail --getmaildir=/home//.getmail -r icloud_Trash || exit 1000
getmail --getmaildir=/home//.getmail -r icloud_Sent || exit 1000

tar cvjf /mnt/backup/Email/iCloud/Archive-`date +%F`.tar.bz2 /tmp/email-backup/iCloud/Archive.mbox || exit 1000
tar cvjf /mnt/backup/Email/iCloud/Deleted_Messages-`date +%F`.tar.bz2 /tmp/email-backup/iCloud/Deleted_Messages.mbox || exit 1000
tar cvjf /mnt/backup/Email/iCloud/Sent_Messages-`date +%F`.tar.bz2 /tmp/email-backup/iCloud/Sent_Messages.mbox || exit 1000

rm -rfv /tmp/email-backup/


# Check if backup files exist, and send notification email.

if [ -f /mnt/backup/Email/iCloud/Archive-`date +%F`.tar.bz2 ]; then 
		echo "The backup of 'Archive' folder completed successfully last night." > /tmp/email-backup-report.log
		echo "Please see below for the file name..." >> /tmp/email-backup-report.log
		echo "" >> /tmp/email-backup-report.log
		ls -lah /mnt/backup/Email/iCloud/Archive-`date +%F`.tar.bz2 >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Archive' on iCloud backup success for " < /tmp/email-backup-report.log
		export SUCCESS1=1
	else
		echo "The backup of the 'Archive' folder on iCloud failed to run last night. Please verify IMAP backup log below..." > /tmp/email-backup-report.log
        	echo "" >> /tmp/email-backup-report.log
		tail /var/log/email-backup/iCloud_Archive.log >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Archive' on iCloud backup failure for " < /tmp/email-backup-report.log
		export SUCCESS1=0
fi

if [ -f /mnt/backup/Email/iCloud/Deleted_Messages-`date +%F`.tar.bz2 ]; then 
		echo "The backup of 'Deleted Messages' folder completed successfully last night." > /tmp/email-backup-report.log
		echo "Please see below for the file name..." >> /tmp/email-backup-report.log
		echo "" >> /tmp/email-backup-report.log
		ls -lah /mnt/backup/Email/iCloud/Deleted_Messages-`date +%F`.tar.bz2 >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Deleted Messages' on iCloud backup success for " < /tmp/email-backup-report.log
		export SUCCESS2=1
	else
		echo "The backup of the 'Deleted Messages' folder on iCloud failed to run last night. Please verify IMAP backup log below..." > /tmp/email-backup-report.log
        	echo "" >> /tmp/email-backup-report.log
		tail /var/log/email-backup/iCloud_Deleted_Messages.log >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Deleted Messages' on iCloud backup failure for " < /tmp/email-backup-report.log
		export SUCCESS2=0
fi

if [ -f /mnt/backup/Email/iCloud/Sent_Messages-`date +%F`.tar.bz2 ]; then 
		echo "The backup of 'Sent Messages' folder completed successfully last night." > /tmp/email-backup-report.log
		echo "Please see below for the file name..." >> /tmp/email-backup-report.log
		echo "" >> /tmp/email-backup-report.log
		ls -lah /mnt/backup/Email/iCloud/Sent_Messages-`date +%F`.tar.bz2 >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Sent Messages' on iCloud backup success for " < /tmp/email-backup-report.log
		export SUCCESS3=1
	else
		echo "The backup of the 'Sent Messages' folder on iCloud failed to run last night. Please verify IMAP backup log below..." > /tmp/email-backup-report.log
        	echo "" >> /tmp/email-backup-report.log
		tail /var/log/email-backup/iCloud_Sent_Messages.log >> /tmp/email-backup-report.log
		sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u "'Sent Messages' on iCloud backup failure for " < /tmp/email-backup-report.log
		export SUCCESS3=0
fi

rm -rfv /tmp/email-backup-report.log

# Clear up old backups
if [[ $SUCCESS1 == 1 ]] && [[ $SUCCESS2 == 1 ]] && [[ $SUCCESS3 == 1 ]]; then
	find /mnt/backup/`hostname -s`/ -iname `hostname -s`*.iso -daystart -mtime +$AGE -exec rm -fv {} \;
else
	echo $SUCCESS1 $SUCCESS2 $SUCCESS3;
fi

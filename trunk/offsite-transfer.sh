#!/bin/bash
# Offsite Backup Transfer Script

SERVERBACKUPLOCAL=/mnt/usb_backup/Backups/Server
SERVERBACKUPREMOTE=/mnt/mac_backup/Server

TOOLSBACKUPLOCAL=/mnt/usb_backup/Backups/Tools
TOOLSBACKUPREMOTE=/mnt/mac_backup/Tools

SVNBACKUPLOCAL=/mnt/usb_backup/Backups/SVN
SVNBACKUPREMOTE=/mnt/mac_backup/SVN

EMAILBACKUPLOCAL=/mnt/usb_backup/Backups/Email/MobileMe
EMAILBACKUPREMOTE=/mnt/mac_backup/Email/MobileMe

if [ -f $SERVERBACKUPLOCAL/server-backup.log ]; then
rm -rfv $SERVERBACKUPREMOTE/*
cp -v $SERVERBACKUPLOCAL/* $SERVERBACKUPREMOTE > $SERVERBACKUPREMOTE/server-backup-transfer.log
rm -rfv $SERVERBACKUPLOCAL/*
fi

if [ -f $TOOLSBACKUPLOCAL/tools-usb-backup.log ]; then
rm -rfv $TOOLSBACKUPREMOTE/*
cp -v $TOOLSBACKUPLOCAL/* $TOOLSBACKUPREMOTE > $TOOLSBACKUPREMOTE/tools-usb-backup-transfer.log
fi
rm -rfv $TOOLSBACKUPLOCAL/*


if [ -f $SVNBACKUPLOCAL/svn-backup.log ]; then
rm -rfv $SVNBACKUPREMOTE/*
cp -v $SVNBACKUPLOCAL/* $SVNBACKUPREMOTE > $SVNBACKUPREMOTE/svn-backup-transfer.log
fi
rm -rfv $SVNBACKUPLOCAL/*


if [ -f /var/log/email-backup/MobileMe_Deleted_Messages.log ]; then
rm -rfv $EMAILBACKUPREMOTE/*
cp -v $EMAILBACKUPLOCAL/* $EMAILBACKUPREMOTE > $EMAILBACKUPREMOTE/email-backup-transfer.log
fi
rm -rfv $EMAILBACKUPLOCAL/*


if [ -f $SERVERBACKUPREMOTE/server-backup.log ]; then
	if [ -f $TOOLSBACKUPREMOTE/tools-usb-backup.log ]; then
		if [ -f $SVNBACKUPREMOTE/svn-backup.log ]; then
			if [ -f $EMAILBACKUPREMOTE/email-backup-transfer.log ]; then
		                echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
		                echo "" >> /var/log/overnight-jobs.log
		                echo "The offsite transfer of backup files from your server to your iMac completed successfully last night." >> /var/log/overnight-jobs.log
		                echo "" >> /var/log/overnight-jobs.log
		                echo "" >> /var/log/overnight-jobs.log
		                echo "" >> /var/log/overnight-jobs.log
	
			else
			        echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
	                        echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
	                        echo "Please view one of the following log files for more information why this job did not complete successfully..." >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
	                        tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
				tail $TOOLSBACKUPREMOTE/tools-backup-transfer.log >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
	                        tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /var/log/overnight-jobs.log			
                                echo "" >> /var/log/overnight-jobs.log
                                tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /var/log/overnight-jobs.log	                        
				echo "" >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
	                        echo "" >> /var/log/overnight-jobs.log
			fi
		else
		        echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	                echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	                echo "Please view one of the following log files for more information why this job did not complete successfully..." >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	                tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	               	tail $SERVERBACKUPREMOTE/tools-backup-transfer.log >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	                tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /var/log/overnight-jobs.log
                        echo "" >> /var/log/overnight-jobs.log
                        tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /var/log/overnight-jobs.log	                        
			echo "" >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log
	                echo "" >> /var/log/overnight-jobs.log		
		fi
	else
		echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	        echo "" >> /var/log/overnight-jobs.log
	        echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /var/log/overnight-jobs.log
	        echo "" >> /var/log/overnight-jobs.log
	        echo "Please view on of the following log files for more information why this job did not complete successfully..." >> /var/log/overnight-jobs.log
	        echo "" >> /var/log/overnight-jobs.log
	        tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /var/log/overnight-jobs.log
	        echo "" >> /var/log/overnight-jobs.log
	        tail $SERVERBACKUPREMOTE/tools-backup-transfer.log >> /var/log/overnight-jobs.log
	        echo "" >> /var/log/overnight-jobs.log
	        tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /var/log/overnight-jobs.log	                        
		echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
                echo "" >> /var/log/overnight-jobs.log
	fi
else
	echo "______________________________________________________________________________________________________________________" >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	echo "Please view on of the following log files for more information why this job did not complete successfully..." >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	tail $SERVERBACKUPREMOTE/tools-backup-transfer.log >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
	echo "" >> /var/log/overnight-jobs.log
fi

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
rm -rf $SERVERBACKUPREMOTE/*
cp -v $SERVERBACKUPLOCAL/* $SERVERBACKUPREMOTE > $SERVERBACKUPREMOTE/server-backup-transfer.log
	if [ -f $SERVERBACKUPREMOTE/server-backup.log ]; then
	rm -rf $SERVERBACKUPLOCAL/*
	else
	fi
else
fi

if [ -f $TOOLSBACKUPLOCAL/tools-usb-backup.log ]; then
rm -rf $TOOLSBACKUPREMOTE/*
cp -v $TOOLSBACKUPLOCAL/* $TOOLSBACKUPREMOTE > $TOOLSBACKUPREMOTE/tools-usb-backup-transfer.log
	if [ -f $TOOLSBACKUPREMOTE/tools-usb-backup.log ]; then
	rm -rf $TOOLSBACKUPLOCAL/*
	else
	fi
else
fi

if [ -f $SVNBACKUPLOCAL/svn-backup.log ]; then
rm -rf $SVNBACKUPREMOTE/*
cp -v $SVNBACKUPLOCAL/* $SVNBACKUPREMOTE > $SVNBACKUPREMOTE/svn-backup-transfer.log
	if [ -f $SVNBACKUPREMOTE/svn-backup.log ]; then
	rm -rf $SVNBACKUPLOCAL/*
	else
	fi
else
fi

if [ -f /var/log/email-backup/MobileMe_Deleted_Messages.log ]; then
rm -rf $EMAILBACKUPREMOTE/*
cp -v $EMAILBACKUPLOCAL/* $EMAILBACKUPREMOTE > $EMAILBACKUPREMOTE/email-backup-transfer.log
        if [ -f $EMAILBACKUPREMOTE/email-backup-transfer.log ]; then
        rm -rf $EMAILBACKUPLOCAL/*
        else
        fi
else
fi

if [ -f $SERVERBACKUPREMOTE/server-backup.log ]; then
	if [ -f $TOOLSBACKUPREMOTE/tools-usb-backup.log ]; then
		if [ -f $SVNBACKUPREMOTE/svn-backup.log ]; then
			if [ -f $EMAILBACKUPREMOTE/email-backup-transfer.log ]; then
		                echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
		                echo "" >> /tmp/overnight-jobs.log
		                echo "The offsite transfer of backup files from your server to your iMac completed successfully last night." >> /tmp/overnight-jobs.log
		                echo "" >> /tmp/overnight-jobs.log
		                echo "" >> /tmp/overnight-jobs.log
		                echo "" >> /tmp/overnight-jobs.log
	
			else
			        echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
	                        echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
	                        echo "Please view one of the following log files for more information why this job did not compelte successfully..." >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
	                        tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
				tail $TOOLSBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
	                        tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /tmp/overnight-jobs.log			
                                echo "" >> /tmp/overnight-jobs.log
                                tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /tmp/overnight-jobs.log	                        
				echo "" >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
	                        echo "" >> /tmp/overnight-jobs.log
			fi
		else
		        echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	                echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	                echo "Please view on of the following log files for more information why this job did not compelte successfully..." >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	                tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	               	tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	                tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /tmp/overnight-jobs.log
                        echo "" >> /tmp/overnight-jobs.log
                        tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /tmp/overnight-jobs.log	                        
			echo "" >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log
	                echo "" >> /tmp/overnight-jobs.log		
		fi
	else
		echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
	        echo "" >> /tmp/overnight-jobs.log
	        echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /tmp/overnight-jobs.log
	        echo "" >> /tmp/overnight-jobs.log
	        echo "Please view on of the following log files for more information why this job did not compelte successfully..." >> /tmp/overnight-jobs.log
	        echo "" >> /tmp/overnight-jobs.log
	        tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	        echo "" >> /tmp/overnight-jobs.log
	        tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	        echo "" >> /tmp/overnight-jobs.log
	        tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /tmp/overnight-jobs.log	                        
		echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
                echo "" >> /tmp/overnight-jobs.log
	fi
else
	echo "______________________________________________________________________________________________________________________" >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	echo "At least one set of backup files failed to transfer last night from your server to your iMac." >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	echo "Please view on of the following log files for more information why this job did not compelte successfully..." >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	tail $SERVERBACKUPREMOTE/server-backup-transfer.log >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	tail $SVNBACKUPREMOTE/svn-backup-transfer.log >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	tail $EMAILBACKUPREMOTE/email-backup-transfer.log >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
	echo "" >> /tmp/overnight-jobs.log
fi

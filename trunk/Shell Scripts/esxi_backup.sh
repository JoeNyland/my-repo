#!/bin/bash
#
# Author:       KPC
#               Stolen and heavily modified by Bob Templeton Dec 2008
#
#               Nov 2009: Changed everything to use ssh remote commands instead of
#                         using the vmware rcli because with EXSi 4.0, the RCLI does
#                         not have write access to vm's.  Therefore, the RCLI can no
#                         longer create snapshots.  This also makes it so no username
#                         and password is needed to accomplish backups.
#
# Description:  Simple BASH script that does the following:
#               Searches remote ESXi servers for list of VM's
#               Supports multiple datastores
#               Snapshots running VM's 
#               Copies VM's to local storage using SCP
#               Compresses VM's using gzip
#               Removes snapshots of running VM's
#               Outputs result to file and sends an email
#               Supports weekly backups
#
# Restrictions: Will not backup VM's with existing snapshots
#
# Requirements: Must have SSH authentication keys setup between 
#               server running this script and the ESXi host.
#               vmdk name must be same as folder
#
#               SSH Authorization Setup
#               Run 'ssh-keygen -t rsa' on RemoteCLI server 
#               Copy /root/.ssh/id_rsa.pub to /.ssh on ESXi server
#               Rename id_rsa.pub to authorized_keys
#               On the ESXi server copy /.ssh to datastore1
#               Add following line to /etc/rc.local: cp /vmfs/volumes/datastore1/.ssh/ /.ssh -R
#
# Restore:      Copy backup directory files to ESXi datastore
#               Browse datastore, Add the vmx file to Inventory                
#               Leave VM name blank
#               Start the VM
#
# Usage:        esxi_backup.sh VM_HOST /destination/directory
#
#####################################################################################################

# Environment variables
HOSTNAME=$1                                                # Hostname or IP address of your ESXi server
BASE_DIR=$2                                                # Base directory where backups will go
LOG_DIR=$BASE_DIR/$1/logs                                  # Location of log directory
DATE=`date +%d%m%y`                                        # Date format for log filename, set to UK (DD/MM/YY)
LOG=$LOG_DIR/vm_$DATE.log                                  # Name of log file
MAILTO=somebody@somewhere.com                              # Email of user(s) to recieve email report (use comma to seperate addresses)
BK_DAILY=$BASE_DIR/$1/$DATE                                # Location of backup directory (ensure these are created first)
DATASTORE_PATH=/vmfs/volumes/datastore1                    # Datastore path on the VM Host

# Delete files and directories older than 5 days
find $BASE_DIR -type f -mtime +5 -print0 | xargs -0 /bin/rm -f
find $BASE_DIR -type d -mtime +5 -print0 | xargs -0 /bin/rm -rf

# Create a new directory for this host if it doesn't already exist
if [ -d $BASE_DIR/$1 ] # directory exists
   then
       EXISTS=true
   else
       mkdir $BASE_DIR/$1
fi

# Create a new directory for the log if it doesn't already exist
if [ -d $LOG_DIR ] # directory exists
   then
       EXISTS=true
   else
       mkdir $LOG_DIR
fi

echo "------------------------------------------------------------------------------------" | tee -a $LOG
echo "ESXi Backup [""$HOSTNAME""] - `date`" | tee -a $LOG
echo "------------------------------------------------------------------------------------" | tee -a $LOG

for i in $( ssh $HOSTNAME "find / -name *.vmx" ); do
        VM_DIR=$(dirname "$i")
        VM_NAME=$(basename "$VM_DIR")
        echo "["$(basename "$VM_DIR")"]" | tee -a $LOG

        # Run the backup only if the VM has no existing snapshots
        if    [ "$(ssh $HOSTNAME "vim-cmd vmsvc/snapshot.get $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx")" != "Get Snapshot:" ]; then
            echo "Snapshot already exists, $VM_NAME backup will be excluded" | tee -a $LOG
        else

                # Create a new directory for today's backup if it doesn't already exist
                if [ -d $BK_DAILY ] # directory exists
                    then
                          EXISTS=true
                    else
                          mkdir $BK_DAILY
                fi

                # Create a new directory for the backup if it doesn't already exist
                if [ -d $BK_DAILY/$VM_NAME ] # directory exists
                    then
                          EXISTS=true
                    else
                          mkdir $BK_DAILY/$VM_NAME
                fi
       
                # Copy vmx file before snapshot is taken
                echo "`date`  -  Staring backup of: $VM_NAME from $1" | tee -a $LOG
                echo "`date`  -  Copying $VM_NAME.vmx from $1" | tee -a $LOG
                scp $HOSTNAME:$VM_DIR/*.vmx $BK_DAILY/$VM_NAME

                # If VM is running create a snapshot 
                if      [ "$(ssh $HOSTNAME "vim-cmd vmsvc/power.getstate $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx | grep Powered")" == "Powered on" ]; then
                        echo "`date`  -  Creating snapshot" | tee -a $LOG
                        ssh $HOSTNAME "vim-cmd vmsvc/snapshot.create $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx vmback 1 1"
                        while [ "$(ssh $HOSTNAME "vim-cmd vmsvc/snapshot.get $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx")" == "Get Snapshot:" ]
                        do
                                sleep 10
                        done

                fi

                # Copy vmdk files 
                echo "`date`  -  Copying virtual disk files" | tee -a $LOG
                scp $HOSTNAME:$VM_DIR/*.vmdk $BK_DAILY/$VM_NAME
         
                # Removing unneeded filest
                echo "`date`  -  Cleaning up" | tee -a $LOG
                rm $BK_DAILY/$VM_NAME/$VM_NAME*-0*
         
                # Compressing files
                #echo "Compressing at `date`" | tee -a $LOG
                #gzip -rf /$BK_DAILY/$VM_NAME  
                 
                # Remove snapshots if any were taken
                if [ "$(ssh $HOSTNAME "vim-cmd vmsvc/power.getstate $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx | grep Powered")" == "Powered on" ]; then
                        echo "`date`  -  Removing snapshots" 
                        ssh $HOSTNAME "vim-cmd vmsvc/snapshot.removeall $DATASTORE_PATH/$VM_NAME/$VM_NAME.vmx"
                fi
 
                echo "`date`  -  Completed backup of $VM_NAME" | tee -a $LOG
                echo "------------------------------------------------------------------------------------" | tee -a $LOG
        fi
done


# Print daily backup directory listing
echo "[Backup Storage Daily]" | tee -a $LOG
du -sh $BK_DAILY/* | tee -a $LOG

# Print Filesystem
echo "------------------------------------------------------------------------------------" | tee -a $LOG
df -h | tee -a $LOG

echo " " | tee -a $LOG
echo "For more info see "$LOG"" | tee -a $LOG

#Statement to mail log file to appropriate users
mail -s "ESXi Backup Report for $HOSTNAME" $MAILTO < $LOG

exit

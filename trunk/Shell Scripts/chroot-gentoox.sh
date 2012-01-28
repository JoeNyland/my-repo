#!/bin/bash
# Script to automate chrooting into Gentoox rootfs from another Linux PC.
# Created by Joe Nyland on 17/01/2012

#
#	Need to setup so that the script can be run like
#	init script (chroot-gentoox.sh [start/exit/status]) (if possible).
#
#	Need option to create mount point, if it does not already exist.
#

ROOTFS=`readlink -f "$1"`
MOUNT=`readlink -f "$2"`
SCRIPTNAME=`basename $0`
SYNTAX="$SCRIPTNAME [Gentoox_rootfs] [mount_point]"
TIMEOUT=30
LOGGER="-p cron.info -t chroot-gentoox"

cat <<EOWELC

###########################################################################
#                                                                         #
#  * Welcome to the MasterRoot24 script to provide a chroot environment   #
#    for Gentoox rootfs file.                                             #
#                                                                         #
#  * You will be prompted for the necessary details below.                #
#                                                                         #
###########################################################################
EOWELC

#	Check if the user is running the script as root.
if [ `id -u` -eq 0 ]; then
	echo ;
else
	echo;
	echo "[ERROR]";
	echo "This script requires root privileges to perform chroot operations.";
	echo "Please re-run the script as root, or using sudo.";
	echo ;
	exit 1001;
fi

#	Check if $1 is empty (rootfs file)
if [ ! -z "$ROOTFS" ]; then
	echo;
else
	echo ;
	echo "[ERROR]";
	echo "You have not specified the rootfs which you would like to chroot into.";
	echo ;
	echo "Please re-run the script, with the following syntax:";
	echo $SYNTAX
	exit 1002;
fi

if [ -f $1 ]; then
	echo ;
else
	echo;
	echo "[ERROR]";
	echo "You have selected an invalid Gentoox rootfs file to chroot into.";
	echo ;
	echo "Please re-run the script, with the following syntax:";
	echo $SYNTAX
	exit 1000;
fi

#	Check if $2 is empty (mount point)
if [ ! -z "$MOUNT" ]; then
	echo;
else
	echo ;
	echo "[ERROR]";
	echo "You have not specified the mount point where you would like the Gentoox rootfs to be mounted.";
	echo ;
	echo "Please re-run the script, with the following syntax:";
	echo $SYNTAX
	exit 1003;
fi

if [ -d $2 ]; then
	echo ;
else
	echo;
	echo "[ERROR]";
	echo "You have selected an invalid mount point.";
	echo ;
	echo "Please re-run the script, with the following syntax:";
	echo $SYNTAX
	exit 1004;
fi

#	Warn user if we are not in a GNU screen session
if [ $TERM != "screen" ]; then
	echo "[WARNING]";
	echo "You are not running this script from a GNU Screen session.";
	echo "As a result, if you exit the session, you will exit from the chroot environment,";
	echo "possibly losing unsaved data.";
	echo ;
	echo "Would you like to proceed anyway?";
	echo "[y/yes] = Proceed, anyway - I know what I'm doing!";
	echo "[n/no] = Exit from the script, to allow me to start a GNU Screen session.";
	read -t 30 -p "Proceed?: " SCREENCHK;
	case $SCREENCHK in
		y|Y|yes|Yes ) echo;;
 		n|N|no|No ) echo
        echo "Script cancelled."
        exit 1010;;
        * ) echo "[ERROR]"
        	echo "Invalid answer."
        	echo 
        	echo "Script cancelled."
       		exit 1011;;
    esac
fi
	
#	Check with the user if the specified rootfs file is correct.
echo "Please confirm the following:"
echo ;
echo "You have selected $ROOTFS as the Gentoox rootfs to chroot into.";
read -n 1 -t 30 -p "Is this correct? [y/n]: " ROOTFSCONF
case "$ROOTFSCONF" in
  y|Y|yes|Yes ) echo;;
  n|N|no|No ) echo
        echo "Script cancelled."
        exit 1005;;
  * ) echo
	echo "[ERROR]"
  	echo "Please try the script again, answering y = yes or n = no."
  	echo "Script cancelled."
	exit 1006;;
esac

echo
#	Check with the user if the specified mount point is correct.
echo "You have selected $MOUNT as the location where the Gentoox chroot environment will be mounted.";
read -n 1 -t 30 -p "Is this correct? [y/n]: " MOUNTPCONF
case "$MOUNTPCONF" in
  y|Y|yes|Yes ) echo;;
  n|N|no|No ) echo
        echo "Script cancelled."
        exit 1006;;
  * ) echo
	echo "[ERROR]"
  	echo "Please try the script again, answering y = yes or n = no."
  	echo "Script cancelled."
	exit 1007;;
esac

#	Log to start of the chroot process to syslog.
echo "Gentoox chroot started." | logger $LOGGER
echo "RootFS: $ROOTFS" | logger $LOGGER
echo "Mount point: $MOUNT" | logger $LOGGER

#	Check to see if selected rootfs is mounted already.
echo
mount -l | grep -i "$ROOTFS" > /dev/null
MOUNTED=$?

case $MOUNTED in
	1 ) ;;
	0 ) echo
	echo "[ERROR]"
	echo "$ROOTFS is currently mounted."
	echo "[ERROR] $ROOTFS is already mounted." | logger $LOGGER
	echo "Script cancelled." | logger $LOGGER;
	exit 1013;;
	* ) echo "[ERROR]"  | logger -s $LOGGER
	echo "General error occured." | logger -s $LOGGER
	echo "Script cancelled." | logger -s $LOGGER
	exit 1008;;
esac

#	Mount rootfs file at mount point.
if mount -t reiserfs $ROOTFS $MOUNT
then
	echo "$ROOTFS mounted successfully at $MOUNT" | logger -s $LOGGER;
else
	echo ;
	echo "[ERROR]" | logger -s $LOGGER;
	echo "Failed to mount rootfs file" | logger -s $LOGGER;
	echo ;
	echo "Script cancelled." | logger -s $LOGGER;
	exit 1009;
fi

#	Mount /proc in chroot environment.
if mount -t proc none $MOUNT/proc
then
	echo "/proc mounted successfully in chroot environment." | logger -s $LOGGER;
else
	echo ;
	echo "[ERROR]" | logger -s $LOGGER;
	echo "Failed to mount /proc" | logger -s $LOGGER;
	echo ;
	echo "Script cancelled." | logger -s $LOGGER;
	exit 1010;
fi

#	Mount /dev in chroot enviroment.
if mount --rbind /dev $MOUNT/dev
then
	echo "/dev mounted successfully in chroot environment." | logger -s $LOGGER
else
	echo ;
	echo "[ERROR]" | logger -s $LOGGER;
	echo "Failed to mount /dev" | logger -s $LOGGER;
	echo ;
	echo "Script cancelled." | logger -s $LOGGER;
	exit 1012;
fi

#	Install setup script intp chroot environment.
touch $MOUNT/tmp/$SCRIPTNAME-setup.sh
cat > $MOUNT/tmp/$SCRIPTNAME-setup.sh <<EOSETUP
#!/bin/bash
env-update
source /etc/profile
/bin/bash
EOSETUP
chmod +x $MOUNT/tmp/$SCRIPTNAME-setup.sh

#	Perform chroot operation.
chroot $MOUNT /tmp/$SCRIPTNAME-setup.sh

#	Exit chroot environment.
echo 
echo "Please confirm you would like the script to start umounting the chroot environment's filesystems."
read -p "Unmount filesystems? [y/n]: " UNMOUNTFS
case "$UNMOUNTFS" in
  y|Y|yes|Yes ) 
  echo "Starting umount of chroot filesystems" | logger $LOGGER
  cd
  
  if rm -rfv $MOUNT/tmp/$SCRIPTNAME-setup.sh > /dev/null
  then
  	echo "$MOUNT/tmp/$SCRIPTNAME-setup.sh successfully uninstalled successfully" | logger $LOGGER
  else
  	echo "[ERROR]: Failed to uninstall $MOUNT/tmp/$SCRIPTNAME-setup.sh" | logger $LOGGER
  fi
  	
  if umount -l $MOUNT/dev{/shm,/pts,}
  then
  	echo "$MOUNT/dev unmounted successfully." | logger $LOGGER
  else
  	echo "[ERROR]: $MOUNT/dev failed to unmount successfully." | logger $LOGGER
  fi
  
  if umount -l $MOUNT/proc
  then
  	echo "$MOUNT/proc unmounted successfully." | logger $LOGGER
  else
  	echo "[ERROR]: $MOUNT/proc failed to unmount successfully." | logger $LOGGER
  fi
  
  if umount -l $MOUNT
  then
  	echo "$MOUNT unmounted successfully." | logger $LOGGER
  else
  	echo "[ERROR]: $MOUNT failed to unmount successfully." | logger $LOGGER
  	echo "Exit with error" | logger $LOGGER
  	exit 1013
  fi
  
  echo 
  echo "All filesystems successfully umounted." | logger -s $LOGGER
  echo Exit | logger $LOGGER
  exit 0;;
esac



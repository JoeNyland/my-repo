#!/bin/bash
# Script to automate chrooting into Gentoox rootfs from another Linux PC.
# Created by Joe Nyland on 17/01/2012

ROOTFS=$1
MOUNT=$2
SCRIPTNAME=`basename $0`
SYNTAX="$SCRIPTNAME [Gentoox_rootfs] [mount_point]"
TIMEOUT=30

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

#	Check with the user if the specified rootfs file is correct.
echo "Please confirm the following:"
echo ;
echo "You have selected $ROOTFS as the Gentoox rootfs to chroot into.";
read -n 1 -t 30 -p "Is this correct? [y/n]" ROOTFSCONF
case "$ROOTFSCONF" in
  y|Y|yes|Yes ) echo;;
  n|N|no|No ) echo
        echo "Script cancelled."
        exit 1005;;
  * ) echo
	echo "[ERROR]"
  	echo "Please try the script again, answering y = yes or n = no."
  	echo "Script cancelled."
	exit 1005;;
esac

echo
#	Check with the user if the specified mount point is correct.
echo "You have selected $MOUNT as the location where the Gentoox chroot environment will be mounted.";
read -n 1 -t 30 -p "Is this correct? [y/n]" MOUNTPCONF
case "$MOUNTPCONF" in
  y|Y|yes|Yes ) echo;;
  n|N|no|No ) echo
        echo "Script cancelled."
        exit 1005;;
  * ) echo
	echo "[ERROR]"
  	echo "Please try the script again, answering y = yes or n = no."
  	echo "Script cancelled."
	exit 1005;;
esac

echo
#
#	Logger
#
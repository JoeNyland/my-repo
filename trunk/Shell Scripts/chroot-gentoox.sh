#!/bin/bash
# Script to automate chrooting into Gentoox rootfs from another Linux PC.
# Created by Joe Nyland on 17/01/2012

ROOTFS=$1
MOUNT=$2

SCRIPTNAME=`basename $0`

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

if [ -f $1 ]; then
	echo "
You have selected $ROOTFS as the Gentoox rootfs to chroot into.";
else
	echo "You have selected an invalid Gentoox rootfs file to chroot into.
Please re-run the script, with the following syntax:
";
cat <<EOSYNTAX
$SCRIPTNAME [Gentoox_rootfs] [mount_point]

EOSYNTAX
exit 1000;
fi

if [ -d $2 ]; then
	echo "
You have selected $MOUNT as the location where the Gentoox chroot
environment will be mounted.";
else
	echo "You have selected an invalid mount point.
Please re-run the script, with the following syntax:
";
cat <<EOSYNTAX
$SCRIPTNAME [Gentoox_rootfs] [mount_point]

EOSYNTAX
exit 1000;
fi


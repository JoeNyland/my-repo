#!/bin/bash
# Restore Script

echo
echo Welcome to the BarryCent script to restore your PC from a backup file.
echo
echo -n Press return to continue.
read ans
clear
echo *WARNING* This script defaults the location of target disk to /media/disk . If this is not the target volume, exit NOW.
echo -n Press return if /media/disk is the target volume.
read ans
mkdir /media/"Freecom Mobile Drive"/"Ubuntu Backups"/"Boot Backup"
cp /media/disk/boot /media/"Freecom Mobile Drive"/"Ubuntu Backups"/"Boot Backup"
clear
echo -n Press return to start restore of backup to: /media/disk . *WARNING* The changes after this stage cannot be undone.
read ans
sudo rm -rf /media/disk/*
sudo tar xvpfj $HOSTNAME.tar.bz2 -C /media/disk
echo Restore of files complete.
echo -n Press return to start reconstruction of filesystem at: /media/disk
read ans
clear
cd /media/disk
sudo mkdir proc
sudo mkdir lost+found
sudo mkdir mnt
sudo mkdir sys
sudo mkdir media
sudo mkdir dev
clear
echo Filesystem reconstruction complete.
echo GRUB needs to be reconfigured. GRUB beckup extracted before restore located at /media/Freecom Mobile Drive/Ubuntu Backups/Boot Backup
sh "Freecom Mobile Drive"/"Ubuntu Backups"/"GRUB Restore Script"
echo -n Press return when you have finished reconfiguring GRUB and you are ready to exit.
read ans
rm -rf /media/"Freecom Mobile Drive"/"Ubuntu Backups"/"Boot Backup"

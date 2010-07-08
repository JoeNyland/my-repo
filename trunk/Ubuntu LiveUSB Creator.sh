#!/bin/sh

# Copyright 2008 - Created by Lance of http://www.pendrivelinux.com
echo "############# USB INSTALLER SCRIPT #############"
echo
echo "This script can be used to create a Ubuntu 8.10"
echo "Persistent USB flashdrive from a 2GB+ USB drive."
echo 
echo "================================================"
echo "================= WARNING! ====================="
echo "================================================"
echo
echo "This USB installer script is being offered AS-IS"
echo "for FREE and comes with absolutely no warranty."
echo "Proceed at your own risk."
echo
echo "If you agree, press Enter to continue..."
read p 
clear
echo "================================================"
sudo fdisk -l
echo
echo "=========== Locate your flash drive ============"
echo
echo "Please locate your flash drive from the list of"
echo "devices displayed above and enter it's letter."
echo
echo "For example, if your flash drive is /dev/sdx,"
echo "you would type x and then press Enter"
echo
echo "What is your drive letter?:"
read X
Y="1" 
Z="2"
sleep 1
clear
echo "=========== Creating the partitions ==========="
echo
if sudo [ -b /dev/sd$X$Y ]; then
sudo umount -f /dev/sd$X$Y
else
echo "dev/sd$X$Y is ready"
fi
sleep 1
if sudo [ -b /dev/sd$X$Z ]; then
sudo umount -f /dev/sd$X$Z
else
echo "dev/sd$X$Z is ready"
fi
sleep 1
sudo parted -s /dev/sd$X rm 1
sudo parted -s /dev/sd$X rm 2
sleep 1
sudo parted -s /dev/sd$X mkpart primary fat32 0 50%
sleep 1
sudo parted -s /dev/sd$X mkpart primary ext2 50% 100%
sleep 1
sudo parted -s /dev/sd$X set 1 boot on
clear
echo "============ Creating filesystem ============"
echo
sudo umount -f /dev/sd$X$Y
sleep 2
sudo mkfs.vfat -F 32 -n ubuntu9 /dev/sd$X$Y
sleep 2
sudo umount -f /dev/sd$X$Z
sleep 2
sudo mkfs.ext2 -b 4096 -L casper-rw /dev/sd$X$Z
clear
echo "============ Stage 1 completed =============="
echo
echo "Please remove and reinsert your flash drive." 
echo "Wait for the mounted partitions to appear on" 
echo "your desktop, and then press Enter to continue"
read p
clear
echo "===== Stage 2: creating the portable USB ===="
echo
echo "Moving on to create the portable system."
echo
# if sudo [ -d /media/casper-rw ]; then
# echo "Directory casper-rw is ready"
# else
# sudo mkdir /media/casper-rw
# sudo mount /dev/sd$X$Z /media/casper-rw
# fi
# sleep 1
# if sudo [ -d /media/ubuntu9 ]; then
# echo "Directory ubuntu9 is ready"
# else
# sudo mkdir /media/ubuntu9
# sudo mount /dev/sd$X$Y /media/ubuntu9
# fi
sudo apt-get install syslinux -y
sleep 3
sudo syslinux -f /dev/sd$X$Y
sleep 2
cd /cdrom
echo
echo "Now copying files to your flash drive." 
echo "Please wait..."
echo
cp -rf casper dists install pics pool preseed .disk isolinux/* md5sum.txt README.diskdefines install/mt86plus /media/ubuntu9
sleep 1
cd /media/ubuntu9
sleep 1
sudo cp isolinux.cfg syslinux.cfg
sleep 1
sudo rm text.cfg
sudo wget pendrivelinux.com/downloads/u810/text.cfg
sleep 1
clear
echo "=========== Stage 2 completed ============="
echo
echo "All finished, your flash drive is now ready"
echo "Press Enter to close this window..."
read p

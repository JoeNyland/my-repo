#! /bin/sh
sudo find /etc -name "*vboxadd*" -exec rm {} \;
sudo find /etc -name "*vboxvfs*" -exec rm {} \;
sudo rm -r /usr/src/vboxadd-*
sudo rm -r /usr/src/vboxvfs-*
sudo rm /usr/sbin/vboxadd-timesync
sudo rm /lib/modules/`uname -r`/misc/vboxadd.ko
sudo rm /lib/modules/`uname -r`/misc/vboxvfs.ko

#!/bin/bash
# Restore Script

echo
echo Welcome to the BarryCent script to restore the GRUB bootloader to your HDD.
echo
gksudo su
grub
echo -n Press return if hd1,0 (/dev/sdb1) is the correct root partition.
read ans
root (hd1,0)
echo -n Press return to setup GRUB on if hd1,0 (/dev/sdb1).
read ans
setup (hd1)
quit

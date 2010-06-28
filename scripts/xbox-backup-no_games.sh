#!/bin/sh
# Xbox Backup Script. Note: this script does not backup Xbox games (/F/Games/) or Gentoox's rootfs or swap files.

BACKUPLOCATION="/mnt/usb_backup/Backups/Xbox/"

echo "Enter your Xbox IP address";

while read inputline
do
xboxip="$inputline"

if [ -z "${xboxip}" ];
then
echo 
echo You need to enter an IP address for your Xbox for this script to connect to the FTP server.;
echo Please re-run this script and enter a valid local IP address for your Xbox.;
echo This script will now exit.;
echo
exit
fi

echo Xbox IP saved.
echo Using IP of $xboxip to connect to Xbox FTP server.

cd $BACKUPLOCATION || exit
rm -rfv ./*.log
echo Backing up source files from Xbox.;
lftp -c mirror ftp://xbox:xbox@/C/
lftp -c mirror ftp://xbox:xbox@/E/
lftp -c mirror ftp://xbox:xbox@/F/ --exclude Games/ --exclude rootfs --exclude swap
# lftp -c mirror ftp://xbox:xbox@/F/ --exclude rootfs --exclude swap
echo Finished backing up source files.;
echo Now compressing with bzip2...;
echo 
echo Compressing C;
tar cvpjf "Xbox C"-`date +%F`.tar.bz2 ./C/ > "Xbox C".log
echo Compressing E;
tar cvpjf "Xbox E"-`date +%F`.tar.bz2 ./E/ > "Xbox E".log
echo Compressinng F;
tar cvpjf "Xbox F"-`date +%F`.tar.bz2 ./F/ > "Xbox F".log
echo The tarballs from your Xbox have been saved to $BACKUPLOCATION;
echo This script will now clear up the source files for these tarballs.;
rm -rfv ./C/ ./E/ ./F/
echo All done! Here are your Xbox tarballs:;
ls $BACKUPLOCATION -lh

done

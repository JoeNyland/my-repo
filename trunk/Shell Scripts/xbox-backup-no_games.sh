#!/bin/bash
# Xbox Backup Script. Note: this script does not backup Xbox games (/F/Games/) or Gentoox's rootfs or swap files.

TEMPBACKUPLOCATION="/tmp/xbox-backup"
BACKUPLOCATION="/mnt/backup/Xbox"
LFTPCONF="$HOME/.lftp"
RETRY="1"
MAXRETSET=` grep -i "set net:max-retries $RETRY" $LFTPCONF/rc|wc -l`

if [ -d $LFTPCONF ];
then

  if [ -f $LFTPCONF/rc ];

  then
    echo An lftp config file exists.

    if [[ $MAXRETSET = 1 ]]

    then
    echo The max retry setting is present in the config file.

    else
    echo The max retry setting is not currently set in the config file.                  
    echo "set net:max-retries $RETRY" >> $LFTPCONF/rc
    echo The max retry setting has now been set in the config file.

    fi

  else
    touch $LFTPCONF/rc
    echo An lftp config file has been created.
    echo "set net:max-retries $RETRY" >> $LFTPCONF/rc
    echo The max retry setting has now been set in the config file.

  fi

else
  mkdir $LFTPCONF
  touch $LFTPCONF/rc
  echo "set net:max-retries $RETRY" >> $LFTPCONF/rc   
  echo The lftp max retry setting has now been set in the config file.

fi


echo "Enter your Xbox IP address";

while read inputline
do
XBOXIP="$inputline"

if [ -z "${XBOXIP}" ];
then
echo 
echo You need to enter an IP address for your Xbox for this script to connect to the FTP server.;
echo Please re-run this script and enter a valid local IP address for your Xbox.;
echo This script will now exit.;
echo
exit
fi

echo Xbox IP saved.
echo Using IP of $XBOXIP to connect to Xbox FTP server.

mkdir -p $TEMPBACKUPLOCATION
cd $TEMPBACKUPLOCATION || exit
echo Backing up source files from Xbox.;
lftp -c mirror ftp://xbox:xbox@$XBOXIP/C/ || exit
lftp -c mirror ftp://xbox:xbox@$XBOXIP/E/
lftp -c mirror ftp://xbox:xbox@$XBOXIP/F/ --exclude ROMs --exclude Games/ --exclude rootfs --exclude swap
# lftp -c mirror ftp://xbox:xbox@$XBOXIP/F/ --exclude rootfs --exclude swap
echo Finished backing up source files.;
echo Now compressing with bzip2...;
echo 
echo Compressing C;
tar cvpjf "Xbox C"-`date +%F`.tar.bz2 ./C/ > "Xbox-Backup-C".log
echo Compressing E;
tar cvpjf "Xbox E"-`date +%F`.tar.bz2 ./E/ > "Xbox-Backup-E".log
echo Compressinng F;
tar cvpjf "Xbox F"-`date +%F`.tar.bz2 ./F/ > "Xbox-Backup-F".log
cp $TEMPBACKUPLOCATION/Xbox* $BACKUPLOCATION || exit

echo The tarballs from your Xbox have been saved to $BACKUPLOCATION;
echo This script will now clear up the source files for these tarballs.;
rm -rfv $TEMPBACKUPLOCATION
echo All done! Here are your Xbox tarballs:;
ls $BACKUPLOCATION -lh --ignore=*.log

exit
done

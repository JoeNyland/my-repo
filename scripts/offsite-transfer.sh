#!/bin/bash
# Offsite Backup Transfer Script

SERVERBACKUPLOCAL=/mnt/usb_backup/Backups/Server/
SERVERBACKUPREMOTE=/mnt/backup/Server/

TOOLSBACKUPLOCAL=/mnt/usb_backup/Backups/Tools\ USB\ Drive/
TOOLSBACKUPREMOTE=/mnt/backup/Tools\ USB\ Drive/

XBOXBACKUPLOCAL=/mnt/usb_backup/Backups/Xbox/
XBOXBACKUPREMOTE=/mnt/backup/Xbox/

rm -rfv $SERVERBACKUPREMOTE/* && cp $SERVERBACKUPLOCAL/* $SERVERBACKUPREMOTE && rm -rf $SERVERBACKUPLOCAL/* > "Server Backup Transfer".log
rm -rfv $TOOLSBACKUPREMOTE/* && cp $TOOLSBACKUPLOCAL/* $TOOLSBACKUPREMOTE && rm -rf $TOOLSBACKUPLOCAL/* > "Tools USB Drive Backup Transfer".log
rm -rfv $XBOXBACKUPREMOTE/* && cp $XBOXBACKUPLOCAL/* $XBOXBACKUPREMOTE && rm -rf $XBOXBACKUPLOCAL/* > "Xbox Backup Transfer".log


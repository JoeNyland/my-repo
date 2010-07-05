#!/bin/bash
# Offsite Backup Transfer Script

SERVERBACKUPLOCAL=/mnt/usb_backup/Backups/Server
SERVERBACKUPREMOTE=/mnt/backup/Server

TOOLSBACKUPLOCAL=/mnt/usb_backup/Backups/Tools
TOOLSBACKUPREMOTE=/mnt/backup/Tools

XBOXBACKUPLOCAL=/mnt/usb_backup/Backups/Xbox
XBOXBACKUPREMOTE=/mnt/backup/Xbox

rm -rfv $SERVERBACKUPREMOTE/* && cp -v $SERVERBACKUPLOCAL/* $SERVERBACKUPREMOTE > $SERVERBACKUPREMOTE/server-backup-transfer.log && rm -rf $SERVERBACKUPLOCAL/*
rm -rfv $TOOLSBACKUPREMOTE/* && cp -v $TOOLSBACKUPLOCAL/* $TOOLSBACKUPREMOTE > $TOOLSBACKUPREMOTE/tools-usb-backup-transfer.log && rm -rf $TOOLSBACKUPLOCAL/*
rm -rfv $XBOXBACKUPREMOTE/* && cp -v $XBOXBACKUPLOCAL/* $XBOXBACKUPREMOTE > $XBOXBACKUPREMOTE/xbox-backup-transfer.log && rm -rf $XBOXBACKUPLOCAL/*

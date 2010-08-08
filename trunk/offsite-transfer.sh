#!/bin/bash
# Offsite Backup Transfer Script

SERVERBACKUPLOCAL=/mnt/usb_backup/Backups/Server
SERVERBACKUPREMOTE=/mnt/backup/Server

TOOLSBACKUPLOCAL=/mnt/usb_backup/Backups/Tools
TOOLSBACKUPREMOTE=/mnt/backup/Tools

XBOXBACKUPLOCAL=/mnt/usb_backup/Backups/Xbox
XBOXBACKUPREMOTE=/mnt/backup/Xbox

SVNBACKUPLOCAL=/mnt/usb_backup/Backups/SVN
SVNBACKUPREMOTE=/mnt/backup/SVN

GENTOOXBACKUPLOCAL=/mnt/usb_backup/Backups/Gentoox
GENTOOXBACKUPREMOTE=/mnt/backup/Gentoox

rm -rf $SERVERBACKUPREMOTE/* && cp -v $SERVERBACKUPLOCAL/* $SERVERBACKUPREMOTE > $SERVERBACKUPREMOTE/server-backup-transfer.log && rm -rf $SERVERBACKUPLOCAL/*
rm -rf $TOOLSBACKUPREMOTE/* && cp -v $TOOLSBACKUPLOCAL/* $TOOLSBACKUPREMOTE > $TOOLSBACKUPREMOTE/tools-usb-backup-transfer.log && rm -rf $TOOLSBACKUPLOCAL/*
rm -rf $SVNBACKUPREMOTE/* && cp -v $SVNBACKUPLOCAL/* $SVNBACKUPREMOTE > $SVNBACKUPREMOTE/svn-backup-transfer.log && rm -rf $SVNBACKUPLOCAL/*
cp -v $XBOXBACKUPLOCAL/* $XBOXBACKUPREMOTE > $XBOXBACKUPREMOTE/xbox-backup-transfer.log && rm -rf $XBOXBACKUPLOCAL/*
cp -v $GENTOOXBACKUPLOCAL/* $GENTOOXBACKUPREMOTE > $GENTOOXBACKUPREMOTE/gentoox-backup-transfer.log && rm -rf $GENTOOXBACKUPLOCAL/*

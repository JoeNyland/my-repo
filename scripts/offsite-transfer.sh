#!/bin/bash
# Offsite Backup Transfer Script

rm -rf /mnt/backup/Tools\ USB\ Drive/* && cp /mnt/usb_backup/Backups/Tools\ USB\ Drive/* /mnt/backup/Tools\ USB\ Drive/ && rm -rf /mnt/usb_backup/Backups/Tools\ USB\ Drive/*
rm -rf /mnt/backup/Server/* && cp /mnt/usb_backup/Backups/Server/* /mnt/backup/Server/ && rm -rf /mnt/usb_backup/Backups/Server/*

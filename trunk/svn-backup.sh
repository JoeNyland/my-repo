#!/bin/bash
# Subversion Repository Backup Script

cd /mnt/usb_backup/Backups/SVN || exit
tar cvpjf SVN-Repositories-`date +%H-%M_%d-%m-%y`.tar.bz2 /srv/svn > svn-backup.log


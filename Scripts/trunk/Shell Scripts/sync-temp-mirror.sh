#!/bin/bash

# This script was written to be setup as a cron job to be run every night whilst maintaining a mirror of /mnt/array on /mnt/backup1 on 

# Rsync /mnt/array/shared, deleting files on the mirror is they have been deleted in the live data location.
rsync -rtph --del --force --progress /mnt/array/shared/ /mnt/backup1/restore/mnt/array/shared/

# Rsync /mnt/array/svn, deleting files on the mirror is they have been deleted in the live data location.
rsync -rtph --del --force --progress /mnt/array/svn/ /mnt/backup1/restore/mnt/array/svn/
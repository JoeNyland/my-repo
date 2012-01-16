#!/bin/bash

# Script to sync from public Gentoo rsync mirrors to local portage mirror.

PUBLICMIRROR=rsync://rsync.uk.gentoo.org
LOCALTREE=/mnt/array/portage-mirror

rsync -hav $PUBLICMIRROR/gentoo-portage $LOCALTREE

if [ $? -eq 0 ]; then
	#rsync completed sucessfully
	logger -ist portage-sync "The local portage mirror was successfully sync'ed with the public mirror: $PUBLICMIRROR ";
	else
	#rsync completed with errors
	logger -ist portage-sync "The portage-sync script completed with errors. Please review any error messages which are displayed when the script is run manually.";
fi
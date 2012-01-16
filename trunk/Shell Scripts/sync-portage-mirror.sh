#!/bin/bash

# Script to sync from public Gentoo rsync mirrors to local portage mirror.

PUBLICMIRROR=rsync://rsync.uk.gentoo.org
LOCALTREE=/mnt/array/portage-mirror

rsync -hav $PUBLICMIRROR/gentoo-portage $LOCALTREE

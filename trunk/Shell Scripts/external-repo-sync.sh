#!/bin/bash

#		!!!	NEED TO CHANGE !!!
# Script to copy from Sourceforge to local

# NOTES
# Copy CVS code from SF Rsync:
#	rsync -av rsync://xbox-linux.cvs.sourceforge.net/cvsroot/xbox-linux/* xbox-linux.rsync/
# Convert CVS repo to SVN dump:
#	cvs2svn --encoding=utf_8 --fallback-encoding=latin_1 --keep-trivial-imports --cvs-revnums --dumpfile=xbox-linux.svn.dmp xbox-linux.rsync/
# Load SVN dump in to SVN repo:
#	svnadmin load /mnt/array/svn/xbox/xbox-linux/ < xbox-linux.svn.dmp
# Remove temp file:
#	rm -rfv xbox-linux.rsync/ xbox-linux.svn.dmp
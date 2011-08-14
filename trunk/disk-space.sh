#!/bin/bash
# Disk space analyser script (using du).

echo
echo There will be a delay while the local filesystem is scanned.
echo
echo Script now starting.
echo 
echo Please wait...
echo 
echo 

if [ -f /usr/bin/gksudo ]; then
gksudo 'du -hx --max-depth=1 '$1''
echo 1
else sudo du -hx --max-depth=1 $1
echo 2
fi
exit

gksudo 'du -hx --max-depth=1 '$1'' || sudo du -hx --max-depth=1 $1


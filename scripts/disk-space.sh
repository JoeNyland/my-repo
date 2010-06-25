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
gksudo du || sudo du -hx --max-depth=1 .

#!/bin/sh

# Adapted from http://treyhunner.com/2011/11/migrating-from-subversion-to-git/

git filter-branch -f --msg-filter '
read msg
if [ -n "$msg" ] ; then
    echo "$msg"
else
    echo "(Empty SVN commit message)"
fi'
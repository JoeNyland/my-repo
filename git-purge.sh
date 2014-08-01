#!/bin/sh
# Adapted from https://help.github.com/articles/remove-sensitive-data

if [[ "$#" > 0 ]]
then
    for i in ""$@""
    do
        git filter-branch --force --index-filter "git rm --cached --ignore-unmatch -r --force $1" --prune-empty --tag-name-filter cat -- --all
    done
    echo "Completed purging the requested files/directories from Git"
    exit 0
else
    echo "ERROR: You have not provided the files/directories that you want to remove from Git"
    echo "Usage: $(basename $0) relative/path/to/file/to/purge"
    exit 1
fi

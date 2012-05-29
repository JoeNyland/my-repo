#!/bin/bash

RECGROUP=$1
TITLE=$2
MYTHUTIL=`which mythutil`

rm -rfv /var/lib/mythtv/videos/${RECGROUP}/${TITLE}*
${MYTHUTIL} --scanvideos
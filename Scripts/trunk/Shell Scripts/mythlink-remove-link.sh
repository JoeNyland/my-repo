#!/bin/bash

RECGROUP=$1
TITLE=$2
MYTHUTIL=`which mythutil`

rm -rfv /var/lib/mythtv/videos/Default/${TITLE}*
${MYTHUTIL} --scanvideos
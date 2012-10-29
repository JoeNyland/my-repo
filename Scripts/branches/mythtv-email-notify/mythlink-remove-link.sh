#!/bin/bash

TITLE=$1
MYTHUTIL=`which mythutil`

rm -rfv /var/lib/mythtv/videos/Default/${TITLE}*
${MYTHUTIL} --scanvideos
#!/bin/bash

# User configurable settings
TO=
SMTPSERVER=
MYTHWEB=
MAIL=sendemail

# Set required variables:
MYTHTV_VER="0.25"			# TODO: Get this from HTTP response from MythWeb
TITLE=$1
SUBTITLE=$2
DESCRIPTION=$3
ORIGINALAIRDATE=$4
PROGSTART=$5
HOSTNAME=`hostname -f`
MAIL=`which $MAIL`

# Check input parameters:
if [ $# -lt 1 ]; then exit 1000; fi

# Main script body
cat html.html | ${MAIL} -f "MythTV@${HOSTNAME}" -t ${TO} -s ${SMTPSERVER} -u "MythTV completed recording ${TITLE}"
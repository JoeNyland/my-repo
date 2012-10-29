#!/bin/bash

COMPLETEJOBS=/var/log/overnight-jobs.log
SMTPSERVER=
SMTPUSERNAME=
SMTPPASSWORD=
SUCCESSSUBJECT="Overnight jobs report from "
FAILURESUBJECT="No jobs to report for "
FROMADDRESS=
TOADDRESS=

if [ -f $COMPLETEJOBS ]

then
	cat $COMPLETEJOBS | sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $SUCCESSSUBJECT
	rm -fv $COMPLETEJOBS
	touch $COMPLETEJOBS
else
	echo "No jobs have run last night or there is nothing to report." | sendemail -f $FROMADDRESS -t $TOADDRESS -s $SMTPSERVER -o username=$SMTPUSERNAME -o password=$SMTPPASSWORD -u $FAILURESUBJECT
fi

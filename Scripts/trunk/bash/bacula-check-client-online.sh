#!/bin/bash

# Script to check whether or not a host is online, in order to decide whether a Bacula backup should be attempted.

HOSTNAME=$1		# Specify the host to test (DNS hostname only).
PORT=9102       # Specify the TCP port to check (Here we check port 9102, which is the default port for the Bacula File Daemon).

if nc -zv -w30 $HOSTNAME $PORT
then
        echo "Port is open";
        exit 0;
else
        echo "Port is closed";
        exit 1;
fi



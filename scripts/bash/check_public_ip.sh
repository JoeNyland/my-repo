#!/bin/bash

recipient=""
current_ip=`curl -s --connect-timeout 300 --max-time 300 icanhazip.com`
last_ip=$current_ip

clear
while true
do
	current_ip=`curl -s --connect-timeout 300 --max-time 300 icanhazip.com`
	if [[ $current_ip == $last_ip ]]
	then
		echo -ne "`date` [INFO] Current public IP is $current_ip"\\r
	else
		date=`date`
		echo 
		echo 
		echo "$date [WARN] Public IP address has changed! Public IP is now $current_ip"
		echo "$date [WARN] Public IP address has changed! Public IP is now $current_ip" | mail -s "[WARN] Public IP address has changed!" $recipient
		echo 
	fi
	last_ip=$current_ip
	sleep 60
done

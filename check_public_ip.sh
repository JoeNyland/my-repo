#!/bin/sh

# Define the recipient of email notifications from the input arg to the script:
recipient=$1

# Define the get-ip() function to obtain the current IP address:
get-ip() {
    current_ip=`curl -s --connect-timeout 300 --max-time 300 icanhazip.com`

    if [ -n "$current_ip" ] # Check if curl has returned an IP
    then
        echo $current_ip    # If so, then we echo the IP out from the function
        return
    else
        sleep 5             # Else, we sleep for 5s
        get-ip              # then re-run the function to try again
    fi
}

current_ip=`get-ip`         # Set the initial value of $current_ip
last_ip=$current_ip         # and $last_ip to the same value

clear
while true                  # Loop until break with CTRL-C
do
    current_ip=`get-ip`     # Get the current IP
    if [[ $current_ip == $last_ip ]]    # If the current IP is the same as the last IP
	then
		echo -ne "`date` [INFO] Current public IP is $current_ip"\\r    # Update the console
	else
		date=`date`           # Else, warn the user on the console and via email
		echo
		echo
		echo "$date [WARN] Public IP address has changed! Public IP is now $current_ip"
		if [ -n "$1" ]
		then
      echo "$date [WARN] Public IP address has changed! Public IP is now $current_ip" | mail -s "[WARN] Public IP address has changed!" $recipient
    fi
		echo
	fi
	last_ip=$current_ip     # Set the current IP as the last IP, ready for the next iteration
	sleep 60                # Sleep for 60s until the next check
done

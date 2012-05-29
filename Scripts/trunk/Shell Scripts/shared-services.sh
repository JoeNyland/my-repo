#!/bin/bash

if [ "$1" == "start" ];
then echo Starting shares...
sudo /etc/init.d/smbd $1
sudo /etc/init.d/nmbd $1
sudo /etc/init.d/netatalk $1
sudo /etc/init.d/avahi-daemon $1
else
if [ "$1" == "stop" ];
then echo Stopping shares...
sudo /etc/init.d/smbd $1
sudo /etc/init.d/nmbd $1
sudo /etc/init.d/netatalk $1
sudo /etc/init.d/avahi-daemon $1
else echo Invalid value specified. Please use either start/stop.
fi
fi
exit


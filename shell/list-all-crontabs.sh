#!/bin/sh
if [[ $(id -u) != 0 ]]
then
  echo 'Need to be root!'
  exit 1
fi
for user in `cut -f1 -d: /etc/passwd`; do printf $user:\ ; crontab -u $user -l; done
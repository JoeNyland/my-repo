#!/bin/bash
echo 
echo Welcome to the MasterRoot gnome-panel restoration script.
echo 
echo This script will restore the gnome-panel to the default settings.
echo 
echo If you do not wish to continue, close this Terminal window, or press Ctrl + C.
echo 
echo Press return to start this gnome-panel restoration script.
echo -n 
read ans
rm -rfv ~/.gconf/apps/panel/*
cp -rfv ~/.gconf/apps/.panel-backup/* ~/.gconf/apps/panel
clear
echo 
echo Restore Complete. This script will restart gnome-panel to apply the changes.
echo 
echo -n Press return to continue.
read ans
killall gnome-panel
clear
sleep 3
echo Script completed successfully!
sleep 1
exit



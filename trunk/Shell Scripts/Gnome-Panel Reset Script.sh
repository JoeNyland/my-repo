#!/bin/bash
echo 
echo Welcome to the BarryCent gnome-panel restoration script.
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
echo Restore Complete. This script will Log you out, then you will need to Log back
echo in to apply changes.
echo 
echo -n Press return to continue.
read ans
clear
echo 
echo You will now be logged out. Please save all open Documents, and close all
echo running programs, to avoid data loss.
echo 
echo -n Press return when you are ready.
read ans
gnome-session-save --kill --silent
exit

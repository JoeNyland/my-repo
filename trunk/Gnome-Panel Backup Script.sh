#!/bin/bash
echo 
echo Welcome to the BarryCent gnome-panel backup script.
echo 
echo This script will backup the gnome-panel.
echo 
echo If you do not wish to continue, close this Terminal window, or press Ctrl + C.
echo 
echo Press return to start this gnome-panel backup script.
echo -n 
read ans
mkdir ~/.gconf/apps/.panel-backup/
cp -rfv ~/.gconf/apps/panel/* ~/.gconf/apps/.panel-backup/
clear
echo 
echo Backup Complete.
echo 
echo -n Press return to exit.
read ans
exit

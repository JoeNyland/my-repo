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
if [ -d ~/.gconf/apps/.panel-backup/ ]
then 
	rm -rfv ~/.gconf/apps/.panel-backup/;
	mkdir ~/.gconf/apps/.panel-backup/;
	cp -rfv ~/.gconf/apps/panel/* ~/.gconf/apps/.panel-backup/;
else
	mkdir ~/.gconf/apps/.panel-backup/;
	cp -rfv ~/.gconf/apps/panel/* ~/.gconf/apps/.panel-backup/;
fi
clear
echo 
echo Backup Complete.
echo 
echo -n Press return to exit.
read ans
exit

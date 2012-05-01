######################################
#	TO DO
#
#	- Catalog exit codes
#	- Script syntax summary
#
######################################


#!/bin/bash

# This script is based heavily on the work of 'Cowbutt' and was taken from the MythTV Wiki.
# The original script can be found here: http://www.mythtv.org/wiki/Mythcommflag-wrapper
# I (Joe Nyland) do not claim any credit for this script. I've merely updated/amended the original script,
# in order for it to work with MythTV 0.25. I've also made changes amendments where I see fit too.

# *** DISCLAIMER ***
# This script works for me. This doesn't mean to say it will work for *everyone*. Use of this script is entirely at your own risk.
# I do not/will not take any responsibility if the use of this script (the code contained in the rest of the file below) causes
# any issues for you, or results in any data loss or damage to any systems.

# My best advice (if you are not sure) is to run this script against some sort of test MythTV system, before deploying to your
# production MythTV environment. As a bare minimum precaution, I would perform a full database backup, before using this script for the first time.
# See the following Wiki page for more information on how to backup your database: http://www.mythtv.org/wiki/Database_Backup_and_Restore

# User preferences:

# Maximum commercial break duration:
# E.g: Allow ad breaks to be upto 400s long by coalescing non-silence
MAXCOMMBREAKSECS=400

# Frame 'safety' margin:
# mytharchivehelper isn't frame-accurate, and mythcommflag won't add final cut pair if the end of the cut is greater
# than the actual final frame, so subtract $ENDFUDGEFRAMES from the value mytharchivehelper returns
ENDFUDGEFRAMES=75

# Silence Threshold:
# -70dB and minimum of 0.15s to be considered 'silent'
MP3SPLT_OPTS="th=-70,min=0.25"

# Log file
# Note: this file must be writable by the mythtv user.
LOGFILE="/var/log/mythtv/mythcommflag-wrapper"

# Copy commercial skiplist to cutlist
# 0=Disabled 1=Enabled
COPYTOCUTLIST=1

# End User preferences.

# Begin dependency checks.

# mytharchivehelper
if command -v mytharchivehelper
then
	MAH=`which mytharchivehelper` 
	echo >>$LOGFILE "mytharchivehelper found at ${MAH}"
else
	echo >>$LOGFILE "mytharchivehelper not found."
	echo >>$LOGFILE "Please install mytharchive from your package manager or edit your configure options for MythTV and rebuild."
	exit 10
fi

# ffmpeg
if command -v ffmpeg
then
	FFMPEG_PATH=`which ffmpeg` 
	echo >>$LOGFILE "ffmpeg found at ${FFMPEG_PATH}"
else
	echo >>$LOGFILE "ffmpeg not found."
	echo >>$LOGFILE "Please install ffmpeg from your package manager."
	exit 11
fi

# mp3splt
if command -v mp3splt
then
	MP3SLT_PATH=`which mp3splt` 
	echo >>$LOGFILE "mp3splt found at ${MP3SLT_PATH}"
else
	echo >>$LOGFILE "mp3splt not found."
	echo >>$LOGFILE "Please install mp3splt from your package manager."
	exit 12
fi

# End dependency checking.

# Search in known locations for MythTV's mysql.txt config file.
MYTHCFG=""
if [ -e $HOME/mysql.txt ]; then
	MYTHCFG="$HOME/mysql.txt"
fi

if [ -e $HOME/.mythtv/mysql.txt ]; then
	MYTHCFG="$HOME/.mythtv/mysql.txt"
fi

if [ "$MYTHCFG" = "" ]; then
	echo >>$LOGFILE "No mysql.txt found in $HOME or $HOME/.mythtv - exiting!"
	exit 13
fi

# Obtian the DB username and password from MythTV's mysql.txt config file.
MYTHHOST=`grep DBHostName <$MYTHCFG | awk -F= '{print $2}'`
MYTHUSER=`grep DBUserName <$MYTHCFG | awk -F= '{print $2}'`
MYTHPASS=`grep DBPassword <$MYTHCFG | awk -F= '{print $2}'`
MYTHDB=`grep DBName <$MYTHCFG | awk -F= '{print $2}'`

# Root of MythTV recordings
RECORDINGSROOT=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select dirname from storagegroup;" $MYTHDB | tail -n +2 | sort | uniq | tr '\n' ' '`

echo >>$LOGFILE "$0 run with [$*] at `date` by `whoami`"
echo >>$LOGFILE "MythTV recordings root is set to: $RECORDINGSROOT"

	silence_detect() {
			# From http://www.mythtv.org/wiki/Silence-detect.sh
	
			local filename=$1
			
			TMPDIR=`mktemp -d /tmp/mythcommflag.XXXXXX` || exit 14		
			
			# Get frame count, then subtract frame 'safety' margin. (3 seconds/75 frames is the default).
			FRAMES=$((`mytharchivehelper --getfileinfo --infile $filename --method=1 --outfile $TMPDIR/streaminfo.xml 2>&1 | grep " frames = " | awk -F"= " '{print $2}'` - ${ENDFUDGEFRAMES}))
			echo >>$LOGFILE "Total frames = $FRAMES (+/- 75)"		
	
			cd $TMPDIR
			touch `basename $filename`.touch
			ionice -c3 nice ffmpeg -i $filename -acodec copy sound.mp3
			ionice -c3 nice mp3splt -s -p $MP3SPLT_OPTS sound.mp3
	
			CUTLIST=`tail --lines=+3 mp3splt.log|sort -g |\
				   awk 'BEGIN{start=0;ORS=","}{if($2-start<'$MAXCOMMBREAKSECS')
				   {finish=$2} else {print int(start*25+1)"-"int(finish*25-25);
				   start=$1; finish=$2;}}END{print int(start*25+1)"-"'$FRAMES'}'`
			echo >>$LOGFILE "silence-detect has generated cutlist: $CUTLIST"
	
			echo >>$LOGFILE "silence-detect(): CHANID=$CHANID, STARTTIME=$STARTTIME, FRAMES=$FRAMES"		
			CUTLIST=`tail --lines=+3 mp3splt.log|sort -g |\
			awk 'BEGIN{start=0;ORS="\n"}{if($2-start<'$MAXCOMMBREAKSECS') {finish=$2} else {print "INSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(start*25+1)",4);\nINSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(finish*25-25)",5);"; start=$1; finish=$2;}}END{print "INSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(start*25+1)",4);\nINSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\",'$FRAMES',5);"}' | sed 's/\"/'\''/g'`
			RC=$?
			
			rm -rf $TMPDIR
	}		

if [ $# -eq 0 ]; then
	# If the script is run with no parameters, error out with exit code 1000.
	exit 1000
else
	if [ $# -eq 4 -a "$1" = "-j" -a "$3" = "-V" ]; then
		JOB=$2
	else
		# We're being used in some other way, run the real mythcommmflag
		echo >>$LOGFILE "Invalid argument combination."
		echo >>$LOGFILE "Running mythcommflag $* instead"
		exec mythcommflag $*
		exit $?
	fi
	echo >>$LOGFILE "Running job $JOB"
		
	HASCUTLIST=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select recorded.cutlist from recorded join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=recorded.chanid and jobqueue.starttime=recorded.starttime;" $MYTHDB | tail -n +2`	
	if [ "$HASCUTLIST" = "1" ]; then
		echo >>$LOGFILE "Program already has a cutlist set."
		echo >>$LOGFILE "COPYTOCUTLIST disabled. the existing cut list has been retained."
		export COPYTOCUTLIST=0
	fi
	
	CALLSIGN=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select channel.callsign from channel join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=channel.chanid;" $MYTHDB | tail -n +2`
	CHANID=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select chanid from jobqueue where jobqueue.id=$JOB;" $MYTHDB | tail -n +2`	
	STARTTIME=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select starttime from jobqueue where jobqueue.id=$JOB;" $MYTHDB | tail -n +2`
	MYTHUTILSTARTTIME=`echo ${STARTTIME} | sed -e 's/-//g' | sed -e 's/://g' | sed -e 's/ //g'`
	echo >>$LOGFILE "Channel callsign is $CALLSIGN"
	echo >>$LOGFILE "Channel ID is $CHANID"
	echo >>$LOGFILE "Recording start time is $STARTTIME"
	BASENAME=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select recorded.basename from recorded join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=recorded.chanid and jobqueue.starttime=recorded.starttime;" $MYTHDB | tail -n +2`	
	echo >>$LOGFILE "Basename is $BASENAME"
	FILENAME=`ionice -c3 nice find ${RECORDINGSROOT} -name $BASENAME`
	echo >>$LOGFILE "Filename is $FILENAME"	

# Notes on callsigns:
# Channel 4 channels seem to work too, but sometimes last cut is too long?
# Fails on FIVER and cuts almost entire recording. Works for other FIVE channels with caveat that they include news bulletins which are't cut

	if [ "$CALLSIGN" = "FIVE USA" -o "$CALLSIGN" = "FIVE" -o "$CALLSIGN" = "Channel 4" -o "$CALLSIGN" = "Channel 4+1" -o "$CALLSIGN" = "More 4" -o "$CALLSIGN" = "E4" -o "$CALLSIGN" = "E4+1" -o "$CALLSIGN" = "Film4" -o "$CALLSIGN" = "ITV1" -o "$CALLSIGN" = "ITV1 +1" -o "$CALLSIGN" = "ITV2" -o "$CALLSIGN" = "ITV2 +1" -o "$CALLSIGN" = "ITV3" -o "$CALLSIGN" = "ITV4" -o "$CALLSIGN" = "Dave" -o "$CALLSIGN" = "Dave ja vu" ]; then	
		echo >>$LOGFILE "Callsign in whitelist - will run silence_detect"		
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=2 where chanid=$CHANID and starttime='${STARTTIME}';" $MYTHDB
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update jobqueue set status=4, comment='MythCommflag is currently flagging commercials on this recording.' where id=$JOB;" ${MYTHDB}
		CUTLIST=""
		echo >>$LOGFILE "silence_detect $FILENAME"
		silence_detect $FILENAME
		echo >>$LOGFILE "silect_detect() set CUTLIST to $CUTLIST"
		export BREAKS=$((`echo "$CUTLIST"|wc -l` / 2))
		echo >>$LOGFILE "$BREAKS break(s) found."
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "$CUTLIST" $MYTHDB
		RC=$?
		echo >>$LOGFILE "Setting skip list in MySQL DB returned $RC"
		if [ $RC -eq 0 ]; then
			mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=1 where chanid=$CHANID and starttime='${STARTTIME}';" ${MYTHDB}
			mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update jobqueue set status=272, comment='Finished (Successfully completed). There were $BREAKS break(s) found in the recording.' where id=$JOB;" ${MYTHDB}			
			if [ $COPYTOCUTLIST -eq 1 ]; then
			echo >>$LOGFILE "mythutilstarttime is $MYTHUTILSTARTTIME"
			mythutil --gencutlist --chanid $CHANID --starttime $MYTHUTILSTARTTIME
				RC=$?
				if [ $RC -eq 0 ]; then
					echo >>$LOGFILE "mythutil --gencutlist successfully copied skip list to cut list"
				else
					echo >>$LOGFILE "mythutil --gencutlist failed, returned $RC"		
				fi
			fi			
		else
			echo >>$LOGFILE "mythcommflag failed; returned $RC"
			mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=0 where chanid=$CHANID and starttime='${STARTTIME}';" ${MYTHDB}
		fi		
	else
		# Not a whitelisted channel for silence_detect
		echo >>$LOGFILE "The requested recording is not on the silence-detect whitelist."
		echo >>$LOGFILE "Running mythcommflag $* instead."
		exec mythcommflag $*
		exit $?
	fi		
fi
echo >>$LOGFILE
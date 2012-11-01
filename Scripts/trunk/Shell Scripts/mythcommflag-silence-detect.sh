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

# Logging
# logger config
LOGGERPREFS="-st mythcommflag -p daemon.info"

# Copy commercial skiplist to cutlist
# 0=Disabled 1=Enabled
COPYTOCUTLIST=0

# End User preferences

# Functions

exit_error() {

# Error handling function.
# "$1" = Exit code

echo "ERROR" | logger ${LOGGERPREFS}

case $1 in
10)
# mytharchivehelper not found/installed
echo "MythArchive has not been found on your system." | logger ${LOGGERPREFS}
echo "Please install this from your package manager." | logger ${LOGGERPREFS}
exit $1
;;

11)
# ffmpeg not found/installed
echo "ffmpeg has not been found on your system." | logger ${LOGGERPREFS}
echo "Please install this from your package manager." | logger ${LOGGERPREFS}
exit $1
;;

12)
# mp3splt not found/installed
echo "mp3splt has not been found on your system." | logger ${LOGGERPREFS}
echo "Please install this from your package manager." | logger ${LOGGERPREFS}
exit $1
;;

13)
# no mysql.txt config file found
echo "A MythTV mysql.txt config file has not been found on your system." | logger ${LOGGERPREFS}
echo "Please correct this to proceed." | logger ${LOGGERPREFS}
exit $1
;;

14)
# unable to create temp directory
echo "The script has been unable to create a temporary working directory." | logger ${LOGGERPREFS}
echo "Please check permissions for the user that MythBackend is running as to proceed." | logger ${LOGGERPREFS}
exit $1
;;

15)
# recording not in channel ID whitelist
echo "The channel that the selected recording is from is not on the `basename $0` whitelist." | logger ${LOGGERPREFS}
exit $1
;;

1000)
# incorrect combination/no parameters
echo "You have supplied an incorrect combination of arguments to the script." | logger ${LOGGERPREFS}
echo "The standard syntax for this script is:" | logger ${LOGGERPREFS}
echo "`basename $0` [-j %JOBID%] [-v %VERBOSELEVEL%]" | logger ${LOGGERPREFS}
exit $1
;;

esac

}

silence_detect() {
		# From http://www.mythtv.org/wiki/Silence-detect.sh

		local filename=$1
		
		TMPDIR=`mktemp -d /tmp/mythcommflag.XXXXXX` || exit_error 14		
		
		# Get frame count, then subtract frame 'safety' margin. (3 seconds/75 frames is the default).
		FRAMES=$((`mytharchivehelper --getfileinfo --infile $filename --method=1 --outfile $TMPDIR/streaminfo.xml 2>&1 | grep " frames = " | awk -F"= " '{print $2}'` - ${ENDFUDGEFRAMES}))
		if [[ $VERBOSE == 1 ]]; then echo "Total frames = $FRAMES (+/- 75)" | logger ${LOGGERPREFS}; fi

		cd $TMPDIR
		touch `basename $filename`.touch
		ionice -c3 nice ffmpeg -i $filename -acodec copy -map 0:1 sound.mp3
		ionice -c3 nice mp3splt -s -p $MP3SPLT_OPTS sound.mp3

		CUTLIST=`tail --lines=+3 mp3splt.log|sort -g |\
			   awk 'BEGIN{start=0;ORS=","}{if($2-start<'$MAXCOMMBREAKSECS')
			   {finish=$2} else {print int(start*25+1)"-"int(finish*25-25);
			   start=$1; finish=$2;}}END{print int(start*25+1)"-"'$FRAMES'}'`
		if [[ $VERBOSE == 1 ]]; then echo "silence-detect has generated cutlist: $CUTLIST" | logger ${LOGGERPREFS}; fi

		CUTLIST=`tail --lines=+3 mp3splt.log|sort -g |\
		awk 'BEGIN{start=0;ORS="\n"}{if($2-start<'$MAXCOMMBREAKSECS') {finish=$2} else {print "INSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(start*25+1)",4);\nINSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(finish*25-25)",5);"; start=$1; finish=$2;}}END{print "INSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\","int(start*25+1)",4);\nINSERT INTO recordedmarkup (chanid,starttime,mark,type) VALUES ('$CHANID',\"'"$STARTTIME"'\",'$FRAMES',5);"}' | sed 's/\"/'\''/g'`
		RC=$?
		
		rm -rf $TMPDIR `if [[ $VERBOSE == 1 ]]; then echo "-v | logger ${LOGGERPREFS}"`
}		

# End functions

# Begin option checks

if [ $# -eq 0 ]; then
		# We're being used in some other way; run the real mythcommmflag
		echo "Invalid argument combination." | logger ${LOGGERPREFS}
		echo "Running mythcommflag $* instead" | logger ${LOGGERPREFS}
		exec mythcommflag $*
		exit $?
	else
		# Read options and arguments supplied to script
		while getopts ":j:J: :v :V" opt; do
			case ${opt} in
			v|V)
			echo "VERBOSE enabled" | logger ${LOGGERPREFS}
			VERBOSE=1;; # Enable $VERBOSE variable
			j|J)
			JOB=${OPTARG} # Assign the job ID to the $JOB variable
			esac;
		done
fi
# End option checks

# Begin dependency checks.

# mytharchivehelper
if command -v mytharchivehelper
then
	MAH=`which mytharchivehelper` 
	if [[ $VERBOSE == 1 ]]; then echo "mytharchivehelper found at ${MAH}" | logger ${LOGGERPREFS}; fi
else
	exit_error 10
fi

# ffmpeg
if command -v ffmpeg
then
	FFMPEG_PATH=`which ffmpeg` 
	if [[ $VERBOSE == 1 ]]; then echo "ffmpeg found at ${FFMPEG_PATH}" | logger ${LOGGERPREFS}; fi
else
	exit_error 11
fi

# mp3splt
if command -v mp3splt
then
	MP3SLT_PATH=`which mp3splt` 
	if [[ $VERBOSE == 1 ]]; then echo "mp3splt found at ${MP3SLT_PATH}" | logger ${LOGGERPREFS}; fi
else
	exit_error 12
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
	exit_error 13
fi

# Obtian the DB username and password from MythTV's mysql.txt config file.
MYTHHOST=`grep DBHostName <$MYTHCFG | awk -F= '{print $2}'`
MYTHUSER=`grep DBUserName <$MYTHCFG | awk -F= '{print $2}'`
MYTHPASS=`grep DBPassword <$MYTHCFG | awk -F= '{print $2}'`
MYTHDB=`grep DBName <$MYTHCFG | awk -F= '{print $2}'`

# Root of MythTV recordings
RECORDINGSROOT=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select dirname from storagegroup;" $MYTHDB | tail -n +2 | sort | uniq | tr '\n' ' '`

echo "$0 run with [$*] at `date` by `whoami`" | logger ${LOGGERPREFS}
echo "Running $0 against job $JOB" | logger ${LOGGERPREFS}
	
HASCUTLIST=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select recorded.cutlist from recorded join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=recorded.chanid and jobqueue.starttime=recorded.starttime;" $MYTHDB | tail -n +2`	
if [ "$HASCUTLIST" = "1" ]; then
	echo "Program already has a cutlist set." | logger ${LOGGERPREFS}
	echo "COPYTOCUTLIST disabled. The original cut list has been retained." | logger ${LOGGERPREFS}
	export COPYTOCUTLIST=0
fi
	
CALLSIGN=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select channel.callsign from channel join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=channel.chanid;" $MYTHDB | tail -n +2`
CHANID=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select chanid from jobqueue where jobqueue.id=$JOB;" $MYTHDB | tail -n +2`	
STARTTIME=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select starttime from jobqueue where jobqueue.id=$JOB;" $MYTHDB | tail -n +2`
MYTHUTILSTARTTIME=`echo ${STARTTIME} | sed -e 's/-//g' | sed -e 's/://g' | sed -e 's/ //g'`
BASENAME=`mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "select recorded.basename from recorded join jobqueue where jobqueue.id=$JOB and jobqueue.chanid=recorded.chanid and jobqueue.starttime=recorded.starttime;" $MYTHDB | tail -n +2`	
FILENAME=`ionice -c3 nice find ${RECORDINGSROOT} -name $BASENAME`

if [[ $VERBOSE == 1 ]]; then
	echo "JOBID is $JOB" | logger ${LOGGERPREFS};
	# Print user settings
	echo "Maximum commercial break length set to ${MAXCOMMBREAKSECS}s" | logger ${LOGGERPREFS};
	echo "Frame 'safety' margin set to ${ENDFUDGEFRAMES}" | logger ${LOGGERPREFS};
	echo "mp3splt options set are ${MP3SPLT_OPTS}" | logger ${LOGGERPREFS};
	echo "logger options set are ${LOGGERPREFS}" | logger ${LOGGERPREFS};
	echo "Copy commercial list to cut list option is set to ${COPYTOCUTLIST}" | logger ${LOGGERPREFS};
	echo "MythTV MySQL config file detected as ${MYTHCFG}" | logger ${LOGGERPREFS};
	echo "MythTV database host detected as ${MYTHHOST}" | logger ${LOGGERPREFS};
	echo "MythTV database detected as ${MYTHDB}" | logger ${LOGGERPREFS};
	echo "MythTV database user detected as ${MYTHUSER}" | logger ${LOGGERPREFS};
	echo "MythTV database password detected as ${MYTHPASS}" | logger ${LOGGERPREFS};
	# Print job info
	echo "Channel callsign is $CALLSIGN" | logger ${LOGGERPREFS};
	echo "Channel ID is $CHANID" | logger ${LOGGERPREFS};
	echo "Recording root directory is set to: $RECORDINGSROOT" | logger ${LOGGERPREFS};
	echo "Recording start time is $STARTTIME" | logger ${LOGGERPREFS};
	echo "Basename is $BASENAME" | logger ${LOGGERPREFS};
	echo "Filename is $FILENAME" | logger ${LOGGERPREFS};
	echo "Start time to be passed to mythutil is $MYTHUTILSTARTTIME" | logger ${LOGGERPREFS};
fi

# Notes on callsigns:
# Channel 4 channels seem to work too, but sometimes last cut is too long?
# Fails on FIVER and cuts almost entire recording. Works for other FIVE channels with caveat that they include news bulletins which are't cut

if [ "$CALLSIGN" = "FIVE USA" -o "$CALLSIGN" = "FIVE" -o "$CALLSIGN" = "Channel 4" -o "$CALLSIGN" = "Channel 4+1" -o "$CALLSIGN" = "More 4" -o "$CALLSIGN" = "E4" -o "$CALLSIGN" = "E4+1" -o "$CALLSIGN" = "Film4" -o "$CALLSIGN" = "ITV1" -o "$CALLSIGN" = "ITV1 +1" -o "$CALLSIGN" = "ITV2" -o "$CALLSIGN" = "ITV2 +1" -o "$CALLSIGN" = "ITV3" -o "$CALLSIGN" = "ITV4" -o "$CALLSIGN" = "Dave" -o "$CALLSIGN" = "Dave ja vu" ]; then	
	if [[ $VERBOSE == 1 ]]; then echo "The recording channel is in whitelist; silence_detect will be run against this recording" | logger ${LOGGERPREFS}; fi
	mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=2 where chanid=$CHANID and starttime='${STARTTIME}';" $MYTHDB
	mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update jobqueue set status=4, comment='`basename $0` is currently flagging commercials on this recording.' where id=$JOB;" ${MYTHDB}
	CUTLIST=""
	if [[ $VERBOSE == 1 ]]; then echo "silence_detect $FILENAME" | logger ${LOGGERPREFS}; fi
	silence_detect $FILENAME
	if [[ $VERBOSE == 1 ]]; then echo "silect_detect() set CUTLIST to $CUTLIST" | logger ${LOGGERPREFS}; fi
	export BREAKS=$((`echo "$CUTLIST"|wc -l` / 2))
	echo "$BREAKS break(s) found." | logger ${LOGGERPREFS}
	mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "$CUTLIST" $MYTHDB
	RC=$?
	if [[ $VERBOSE == 1 ]]; then echo "Setting skip list in MySQL DB returned $RC" | logger ${LOGGERPREFS}; fi
	if [ $RC -eq 0 ]; then
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=1 where chanid=$CHANID and starttime='${STARTTIME}';" ${MYTHDB}
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update jobqueue set status=272, comment='Finished (Successfully completed). There were $BREAKS break(s) found in the recording.' where id=$JOB;" ${MYTHDB}			
		if [ $COPYTOCUTLIST -eq 1 ]; then
		mythutil --gencutlist --chanid $CHANID --starttime $MYTHUTILSTARTTIME
			RC=$?
			if [ $RC -eq 0 ]; then
				if [[ $VERBOSE == 1 ]]; then echo "mythutil --gencutlist successfully copied skip list to cut list" | logger ${LOGGERPREFS}; fi
			else
				echo "mythutil --gencutlist failed, returned $RC" | logger ${LOGGERPREFS}		
			fi
		fi			
	else
		echo "mythcommflag failed; returned $RC" | logger ${LOGGERPREFS}
		mysql -h${MYTHHOST} -u${MYTHUSER} -p${MYTHPASS} -e "update recorded set commflagged=0 where chanid=$CHANID and starttime='${STARTTIME}';" ${MYTHDB}
	fi		
else
	# Not a whitelisted channel for silence_detect
	echo "The requested recording is not on the silence-detect whitelist." | logger ${LOGGERPREFS}
	echo "Running mythcommflag $* instead." | logger ${LOGGERPREFS}
	exec mythcommflag $*
	exit $?
fi
echo "$0 finished successfully at `date`" | logger ${LOGGERPREFS}
exit 0

#!/usr/bin/env python

import argparse
import urllib2
import time
import calendar
from datetime import datetime
from dateutil import tz
from socket import getfqdn
from lxml import etree

# Define MythWeb URL:
mythweb = ""

parser = argparse.ArgumentParser()
parser.add_argument("--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("--chanid", type=int, help="The %%CHANID%% for the recording to query for")
parser.add_argument("--starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for")
args = parser.parse_args()

server = getfqdn("")
recording_url = "http://" + server + ":6544/Dvr/GetRecorded?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)

starttime_tuple = time.strptime(args.starttime, "%Y-%m-%dT%H:%M:%SZ")
starttime_unix = calendar.timegm(starttime_tuple)

mythweb_url = mythweb + "/tv/detail/" + str(args.chanid) + "/" + str(starttime_unix)

starttime_utc = datetime.strptime(args.starttime, "%Y-%m-%dT%H:%M:%SZ")
starttime_utc = starttime_utc.replace(tzinfo=tz.tzutc())
starttime_local = starttime_utc.astimezone(tz.tzlocal())
starttime_local = starttime_local.replace(tzinfo=None)
startdatetime_local = str(starttime_local).split()
startdate_local = datetime.strptime(str(starttime_local), "%Y-%m-%d %H:%M:%S").strftime("%d/%m/%Y")
starttime_local = startdatetime_local[1]

response = urllib2.urlopen(recording_url)
html_data = response.read()
response.close()

tree = etree.XML(html_data)

title_tag = tree.xpath('//Program/Title')
subtitle_tag = tree.xpath('//Program/SubTitle')
desc_tag = tree.xpath('//Program/Description')

title = title_tag[0].text
subtitle = subtitle_tag[0].text
desc = desc_tag[0].text

# Verbose output:
if args.verbose:
	print """
__________________________________________________________________________________________
Verbose output:

Channel ID: %s
Raw Start Date/Time: %s
Local Start Time: %s
Local Start Date: %s
Title: %s
Subtitle: %s
Description: %s

MythWeb URL: %s
Services URL: %s
Services HTML: 
%s""" %(str(args.chanid), args.starttime, starttime_local, startdate_local, title, subtitle, desc, mythweb_url, recording_url, html_data)


"""
TO DO:
- Handle urllib2.urlopen exceptions OR Get lxml to read directly
- Channel logo
	http://:6544/Guide/GetChannelIcon?ChanId=1019
- Recording preview
	http://:6544/Content/GetPreviewImage?ChanId=1019&StartTime=2012-10-02T19:59:00
- Check for required packages:
	sudo apt-get install python-lxml python-dateutil
"""
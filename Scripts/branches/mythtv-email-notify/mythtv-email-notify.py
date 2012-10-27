#!/usr/bin/env python

import argparse
import urllib2
from socket import getfqdn
from lxml import etree

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("chanid", type=int, help="The %%CHANID%% for the recording to query for")
parser.add_argument("starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for")
args = parser.parse_args()

server = getfqdn()
recording_url = "http://" + server + ":6544/Dvr/GetRecorded?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)

response = urllib2.urlopen(recording_url)
html_data = response.read()
response.close()

tree = etree.XML(html_data)

desc_tag = tree.xpath('//Program/Description')
desc = desc_tag[0].text
print desc

# Verbose output:
if args.verbose:
	print """
__________________________________________________________________________________________
Verbose output:
HTML: 
%s
URL: %s
Channel ID: %s
Start Time: %s""" %(html_data, url, str(args.chanid), args.starttime)

"""
TO DO:
Handle urllib2.urlopen exceptions.
Channel logo
	http://:6544/Guide/GetChannelIcon?ChanId=1019
Recording preview
	http://:6544/Content/GetPreviewImage?ChanId=1019&StartTime=2012-10-02T19:59:00
Link to MythWeb
Check for required packages:
	sudo apt-get install python-lxml
"""
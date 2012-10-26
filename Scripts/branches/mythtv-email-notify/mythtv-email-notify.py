#!/usr/bin/env python

import argparse
import BeautifulSoup
import urllib2
from socket import getfqdn

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("chanid", type=int, help="The %%CHANID%% for the recording to query for")
parser.add_argument("starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for")
args = parser.parse_args()

server = getfqdn()
url = "http://" + server + ":6544/Dvr/GetRecorded?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)

response = urllib2.urlopen(url)
html_data = response.read()
response.close()

print getfqdn()

#soup = BeautifulSoup(''.join(html_data))

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
"""
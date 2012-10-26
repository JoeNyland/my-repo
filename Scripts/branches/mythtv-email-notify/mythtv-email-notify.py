#!/usr/bin/env python

import argparse
import BeautifulSoup
import urllib2

parser = argparse.ArgumentParser()
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
parser.add_argument("chanid", type=int, help="The %%CHANID%% for the recording to query for")
parser.add_argument("starttime", help="The %%STARTTIMEISOUTC%% for the recording to query for")
args = parser.parse_args()

url = "http://:6544/Dvr/GetRecorded?StartTime=" + args.starttime + "&ChanId=" + str(args.chanid)

response = urllib2.urlopen(url)
html_data = response.read()
response.close()

#soup = BeautifulSoup(''.join(html_data))

# Verbose output:
if args.verbose:
	print html_data
	print
	print url
	print args.chanid
	print args.starttime
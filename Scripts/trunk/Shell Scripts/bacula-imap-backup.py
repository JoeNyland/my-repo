#!/usr/bin/env python

import argparse
import os
import sys
import subprocess
import shutil
from string import replace
from imapbackup import *

# Parse the supplied arguments:
parser = argparse.ArgumentParser()
parser.add_argument("-s", "--server", help="Address of server, port optional, eg. mail.com:143")
parser.add_argument("--ssl", help="Use SSL.  Port defaults to 993.", action="store_true")
parser.add_argument("-u", "--username", help="Username to log into server")
parser.add_argument("-p", "--password", help="Password to log into server")
parser.add_argument("-c", "--cleanup", help="Cleanup temp files", action="store_true")
parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose output")
args = parser.parse_args()

# Cleanup routine:
if args.cleanup:
	try:
		shutil.rmtree(DESTINATION)
	except OSError:
		print "An error occurred whilst removing temporary mbox files"
		sys.exit(100)
	print "Successfully cleaned up temporary mbox files."
	sys.exit(0)

if args.ssl:
	ssl = "--ssl"
else:
	ssl = ""
dir = os.path.dirname(os.path.realpath(__file__))
dir = dir.replace(" ", "\ ")
imapbackup = "{dir}/imapbackup.py --server {server} --user {username} --pass {password} {ssl}".format(dir=dir, server=args.server, username=args.username, password=args.password, ssl=ssl)
try:
	subprocess.check_call(imapbackup, shell=True)
except OSError:
	print "An error occurred whilst running imapbackup.py"
	sys.exit(100)

# Verbose output:
if args.verbose:
	print """
__________________________________________________________________________________________
Verbose output:
Server: {server}
SSL: {ssl}
Username: {username}
Password: {password}
Cleanup: {cleanup}
imapbackup.py cmd: {cmd}
""".format(server=args.server, ssl=args.ssl, username=args.username, password=args.password, cleanup=args.cleanup, cmd=imapbackup)
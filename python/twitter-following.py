#!/usr/bin/env python

'''
Takes a list of Twitter User IDs and exports or imports (follows) them.

TODO:
* Allow import of users, and follow them
* Improve error handling
'''

import argparse
import csv
import twitter

parser = argparse.ArgumentParser(description='Import or Export followed Twitter users.')
parser.add_argument('action', choices=['import', 'export'], help=('Choose whether to import or export the list of users followed'))
parser.add_argument('--api-key', required=True, dest='api_key', help='Twitter API key')
parser.add_argument('--api-secret', required=True, dest='api_secret', help='Twitter API secret')
parser.add_argument('--token', required=True, help='Twitter Access token')
parser.add_argument('--token-secret', required=True, dest='token_secret', help='Twitter Access token secret')
parser.add_argument('--csv-file', dest='csv_file', help='Input/Output CSV formatted file')
args = parser.parse_args()

# Authenticate with Twitter
api = twitter.Api(args.api_key,
                  args.api_secret,
                  args.token,
                  args.token_secret)

following = api.GetFriends()                # Get the list of users that this user is following

# Decide what we are going to do: import or export
if args.action == 'import':
    # User wants to import
    raise Exception('Import unimplemented...')
elif args.action == 'export': 
    # User wants to export
    
    # Check to see if the user defined an output file
    try:
        args.csv_file
    except NameError:
        args.csv_file = None
    
    if args.csv_file is None:
        csv_file = 'followed.csv'               # If not defined, default to followed.csv in $PWD
    else:
        csv_file = args.csv_file                # Else, set the output filename to the one provided by the user
    
    # Prepare the CSV file
    csv_file = open(csv_file, 'w')
    writer = csv.writer(csv_file)

    # Write header to CSV file
    writer.writerow(['ScreenName','Name','ID'])
    
    # For each user followed, write their screen name, real name and ID to the file
    for user in following:    
        screenname = user.screen_name
        name = user.name
        id = user.id
        writer.writerow(['@' + screenname, name, id])
    csv_file.close()
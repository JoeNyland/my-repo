#!/usr/bin/env python

'''
Takes a list of Twitter User IDs and exports or imports (follows) them.

TODO:
* Implement argparse
* Allow import of users, and follow them
* Improve error handling
'''

import csv
import twitter

# TODO: Take the following variables from argparse
consumer_key        = ""
consumer_secret     = ""
access_token_key    = ""
access_token_secret = ""
csvfile             = "followers.csv"

# Prepare the CSV file
csvfile = open(csvfile, 'w')                # Open the file for writing
writer = csv.writer(csvfile)

# Authenticate with Twitter
api = twitter.Api(consumer_key,
                  consumer_secret,
                  access_token_key,
                  access_token_secret)

following = api.GetFriends()                # Get the list of users that this user is following
writer.writerow(['ScreenName','Name','ID']) # Write header to CSV file
for user in following:    
    screenname = user.screen_name
    name = user.name
    id = user.id
    writer.writerow(['@' + screenname, name, id]) # For each user followed, write their screen name, real name and ID to the file

csvfile.close()                             # Close the file
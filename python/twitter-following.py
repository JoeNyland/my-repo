#!/usr/bin/env python

'''
ABOUT
Takes a list of Twitter User IDs and exports or imports (follows) them.
'''

import sys
import argparse
import twitter
import csv

# Parse command line arguments
parser = argparse.ArgumentParser(description='Import or Export followed Twitter users.')
parser.add_argument('action', choices=['import', 'export'], help=('Choose whether to import or export the list of users followed'))
parser.add_argument('--api-key', required=True, dest='api_key', help='Twitter API key')
parser.add_argument('--api-secret', required=True, dest='api_secret', help='Twitter API secret')
parser.add_argument('--token', required=True, help='Twitter Access token')
parser.add_argument('--token-secret', required=True, dest='token_secret', help='Twitter Access token secret')
parser.add_argument('--csv-file', dest='csv_file', help='Input/Output CSV formatted file')
args = parser.parse_args()

# Authenticate with Twitter API
def auth_api():
    api = twitter.Api(args.api_key,
                      args.api_secret,
                      args.token,
                      args.token_secret)
    return api

def get_user(api):
    # Return the User object for the authenticated user
    user = api.VerifyCredentials()
    return user

def input_file():
    # Check to see if the user defined an input/output CSV file
    try:
        args.csv_file
    except NameError:
        args.csv_file = None

    if args.csv_file is None:
        # If not defined, default to followed.csv in $PWD
        csv_file = 'followed.csv'
    else:
        # If not defined, default to followed.csv in $PWD
        csv_file = args.csv_file
    
    return csv_file

def import_users(api, user, csv_file):
    # Prepare the CSV file for reading
    csv_file = open(csv_file, 'r')
    reader = csv.reader(csv_file)

    print 'Importing friends of @' + user.GetScreenName() + '...'

    # Follow each user in file
    next(reader, None)  # Skip the header of the CSV
    for line in reader:
        api.CreateFriendship(user_id=line[2])
        print 'Following user: ' + line[0]
    
    print 'Finished importing users that @' + user.GetScreenName() + ' follows.'
    
    csv_file.close()
    api.ClearCredentials()
    
    return True

def export_users(api, user, csv_file):
    # Prepare the CSV file for writing
    csv_file = open(csv_file, 'w')
    writer = csv.writer(csv_file)

    # Get the list of users that this user is following
    following = api.GetFriends()

    print 'Exporting friends of @' + user.GetScreenName() + '...'
    
    # Write header to CSV file
    writer.writerow(['ScreenName','Name','ID'])

    # For each user followed, write their screen name, real name and ID to the file
    for friend in following:    
        screenname = friend.screen_name
        name = friend.name
        id = friend.id
        writer.writerow(['@' + screenname, name, id])
        print 'Exported friendship with user: @' + screenname   
    
    print 'Finished exporting users that @' + user.GetScreenName() + ' is following.'
    
    csv_file.close()
    
    return True

def main():
    # Initialise and authenticate with Twitter API
    api = auth_api()
    
    # Initialise User object
    user = get_user(api)
    
    # Set the CSV file name
    csv_file = input_file()
    
    # Import or export?
    if args.action == 'import':
        # User wants to import
        import_users(api, user, csv_file)    
    elif args.action == 'export': 
        # User wants to export
        export_users(api, user, csv_file)        
    else:
        # This should never happen, but...
        raise Exception("Undefined action: Should be 'import' or 'export'")

# Actually run the main() function and catch any exceptions
try:
    main()
except Exception:
   print 'An error occurred!'
   sys.exit(1)
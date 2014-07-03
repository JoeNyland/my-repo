#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
ABOUT
Takes a list of Twitter User IDs and exports or imports (follows) them.
'''

import sys
import argparse
import twitter

# Parse command line arguments
parser = argparse.ArgumentParser(description='Import or Export followed Twitter users.')
parser.add_argument('action', choices=['import', 'export'], help=('Choose whether to import or export the list of users followed'))
parser.add_argument('--api-key', required=True, dest='api_key', help='Twitter API key')
parser.add_argument('--api-secret', required=True, dest='api_secret', help='Twitter API secret')
parser.add_argument('--token', required=True, help='Twitter Access token')
parser.add_argument('--token-secret', required=True, dest='token_secret', help='Twitter Access token secret')
parser.add_argument('--userfile', help='Input/Output file contain followed users')
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
    # Check to see if the user defined an input/output file
    try:
        args.userfile
    except NameError:
        args.userfile = None

    if args.userfile is None:
        # If not defined, default to followed-users.txt in $PWD
        user_file = 'followed-users.txt'
    else:
        # If not defined, default to followed-users.txt in $PWD
        user_file = args.userfile
    
    return user_file

def import_users(api, user, user_file):
    # Prepare the file for reading
    user_file = open(user_file, 'r')
    user_file_sorted = reversed(user_file.readlines())

    print 'Importing friends of @' + user.GetScreenName() + '...'

    # Follow each user in file
    for line in user_file_sorted:
        friend_id = line.rstrip()
        friend = api.CreateFriendship(friend_id)
        print 'Now following user: @' + friend.screen_name + '...'
    
    print 'Finished importing users that @' + user.GetScreenName() + ' follows.'
    
    user_file.close()
    api.ClearCredentials()
    
    return True

def export_users(api, user, user_file):
    # Prepare the file for writing
    user_file = open(user_file, 'w')

    # Get the list of users that this user is following
    following = api.GetFriends()

    print 'Exporting friends of @' + user.GetScreenName() + '...'
    
    # For each user followed, write their ID to the file
    for friend in following:
        screen_name = friend.screen_name
        id = str(friend.id) + '\n'
        user_file.write(id)
        print 'Exported friendship with user: @' + screen_name + '.'
    
    print 'Finished exporting users that @' + user.GetScreenName() + ' is following.'
    
    user_file.close()
    api.ClearCredentials()
    
    return True

def main():
    # Initialise and authenticate with Twitter API
    api = auth_api()
    
    # Initialise User object
    user = get_user(api)
    
    # Set the file name
    user_file = input_file()
    
    # Import or export?
    if args.action == 'import':
        # User wants to import
        import_users(api, user, user_file)
    elif args.action == 'export': 
        # User wants to export
        export_users(api, user, user_file)
    else:
        # This should never happen, but...
        raise Exception("Undefined action: Should be 'import' or 'export'")

# Actually run the main() function and catch any exceptions
try:
    main()
except Exception:
   print 'An error occurred!'
   sys.exit(1)
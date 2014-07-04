#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
ABOUT
Takes a list of Twitter user IDs and exports or imports (follows) them.
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
parser.add_argument('--user-file', dest='user_file', help='Input/Output file containing followed users')
parser.add_argument('--enable-notifications', dest='notifications', help='When importing, use this argument to enable notifications for the new friend(s) being created', action='store_true')
args = parser.parse_args()

def auth_api():
    # Authenticate with Twitter API
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
        args.user_file
    except NameError:
        args.user_file = None
    
    if args.user_file is None:
        # If not defined, default to followed-users.txt in $PWD
        user_file = 'followed-users.txt'
    else:
        # If not defined, default to followed-users.txt in $PWD
        user_file = args.user_file
    
    return user_file

def export_users(api, user, user_file):
    # Prepare the file for writing
    user_file = open(user_file, 'w')
    
    # Get the list of users that this user is following
    friends = api.GetFriends()
    
    print 'Exporting users that @' + user.GetScreenName() + ' follows...'
    
    # For each user followed, write their ID to the file
    for friend in friends:
        screen_name = friend.screen_name
        id = str(friend.id) + '\n'
        user_file.write(id)
        print 'Exported friendship with user: @' + screen_name + '.'
    
    print 'Finished exporting users that @' + user.GetScreenName() + ' is following.'
    
    user_file.close()
    api.ClearCredentials()
    
    return True

def import_users(api, user, user_file, notifications=False):
    # Prepare the file for reading
    user_file = open(user_file, 'r')
    user_file_sorted = reversed(user_file.readlines())
    
    print 'Importing users that @' + user.GetScreenName() + ' follows...'
    
    # Follow each user in file
    for line in user_file_sorted:
        friend_id = line.rstrip()
        friend = api.CreateFriendship(friend_id, follow=notifications)
        print 'Now following user: @' + friend.screen_name + '...'
    
    print 'Finished importing users that @' + user.GetScreenName() + ' follows.'
    
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
        import_users(api, user, user_file, args.notifications)
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


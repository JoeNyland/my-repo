#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
ABOUT
Takes a list of Twitter friend IDs and exports or imports (follows) them.
'''

import sys
import argparse
import twitter

# Parse command line arguments
parser = argparse.ArgumentParser(description='Import or Export followed Twitter friends.')
parser.add_argument('action', choices=['import', 'export'], help=('Choose whether to import or export the list of friends followed'))
parser.add_argument('--api-key', required=True, dest='api_key', help='Twitter API key')
parser.add_argument('--api-secret', required=True, dest='api_secret', help='Twitter API secret')
parser.add_argument('--token', required=True, help='Twitter Access token')
parser.add_argument('--token-secret', required=True, dest='token_secret', help='Twitter Access token secret')
parser.add_argument('--file', dest='friends_file', help='Input/Output file containing friends')
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
        args.friends_file
    except NameError:
        args.friends_file = None
    
    if args.friends_file is None:
        # If not defined, default to twitter-friends.txt in $PWD
        friends_file = 'twitter-friends.txt'
    else:
        friends_file = args.friends_file
    
    return friends_file

def export_friends(api, user, friends_file):
    # Prepare the file for writing
    friends_file = open(friends_file, 'w')
    
    # Get the list of friends that this user is following
    friends = reversed(api.GetFriends())
    
    print 'Exporting @' + user.GetScreenName() + "'s friends..."
    
    # For each friend followed, write their ID to the file
    for friend in friends:
        screen_name = friend.screen_name
        id = str(friend.id) + '\n'
        friends_file.write(id)
        print 'Exported friendship with: @' + screen_name + '.'
    
    print 'Finished exporting @' + user.GetScreenName() + "'s friends."
    
    friends_file.close()
    api.ClearCredentials()
    
    return True

def import_friends(api, user, friends_file, notifications=False):
    # Prepare the file for reading
    friends_file = open(friends_file, 'r')
    
    print 'Importing @' + user.GetScreenName() + "'s friends..."
    
    # Follow each friend in file
    for line in friends_file:
        friend_id = line.rstrip()
        friend = api.CreateFriendship(friend_id, follow=notifications)
        print 'Following: @' + friend.screen_name + '...'
    
    print 'Finished importing @' + user.GetScreenName() + "'s friends."
    
    friends_file.close()
    api.ClearCredentials()
    
    return True

def main():
    # Initialise and authenticate with Twitter API
    api = auth_api()
    
    # Initialise User object
    user = get_user(api)
    
    # Set the file name
    friends_file = input_file()
    
    # Import or export?
    if args.action == 'export':
        # User wants to export friends
        export_friends(api, user, friends_file)
    elif args.action == 'import':
        # User wants to import friends
        import_friends(api, user, friends_file, args.notifications)
    else:
        # This should never happen, but...
        raise Exception("Undefined action: Should be 'import' or 'export'")

# Actually run the main() function and catch any exceptions
try:
    main()
except Exception:
    print 'An error occurred!'
    sys.exit(1)


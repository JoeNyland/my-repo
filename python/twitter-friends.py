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
parser.add_argument('action', choices=['import', 'export'], help='Choose whether to import or export the list of friends followed')
parser.add_argument('--api-key', required=True, dest='api_key', help='Twitter API key')
parser.add_argument('--api-secret', required=True, dest='api_secret', help='Twitter API secret')
parser.add_argument('--token', required=True, help='Twitter Access token')
parser.add_argument('--token-secret', required=True, dest='token_secret', help='Twitter Access token secret')
parser.add_argument('--file', '-f', help='Input/Output file containing friends, defaults to friends.txt')
parser.add_argument('--enable-notifications', dest='notifications', help='When importing, use this argument to enable notifications for the new friend(s) being created', action='store_true')
parser.add_argument('--verbose', '-v', action='store_true')
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

def out_file():
    # Check to see if the user defined an input/output file
    if args.file == None:
        return sys.stdout
    else:
        return open(args.file, 'w')

def in_file():
    # Check to see if the user defined an input/output file
    if args.file == None:
        return sys.stdin
    else:
        return open(args.file, 'r')

def export_friends(api, user):
    # If out_file() returns std.out, then redirect std.out to std.err
    if out_file().name == '<stdout>':
        output = sys.stdout         # Save stdout as output
        sys.stdout = sys.stderr     # Now, redirect stdout to stderr (for printing messages)
    else:
        output = out_file()         # Not outputting to stdout, so just set output to the file

    # Get the list of friends that this user is following
    friends = reversed(api.GetFriends())
    
    print 'Exporting @' + user.GetScreenName() + "'s friends..."
    
    # For each friend followed, write their ID to the file
    for friend in friends:
        output.write(str(friend.id) + '\n')
        if args.verbose:
            print 'Exported friendship with: @' + friend.screen_name + '.'
    
    print 'Finished exporting @' + user.GetScreenName() + "'s friends."
    
    output.close()
    api.ClearCredentials()
    
    return True

def import_friends(api, user, notifications=False):
    # Check that the input file contains data
    if in_file().name != '<stdin>' and len(open(args.file, 'r').readlines()) == 0:
        raise Exception({"message":"Error: No friend ID's found in file!"})
    
    print 'Importing @' + user.GetScreenName() + "'s friends..."
    
    # Follow each friend in file
    for line in in_file().readlines():
        friend_id = line
        friend = api.CreateFriendship(friend_id, follow=notifications)
        if args.verbose:
            print 'Following: @' + friend.screen_name + '...'
    
    print 'Finished importing @' + user.GetScreenName() + "'s friends."
    
    in_file().close()
    api.ClearCredentials()
    
    return True

def main():
    # Initialise and authenticate with Twitter API
    api = auth_api()
    
    # Initialise User object
    user = get_user(api)
    
    # Import or export?
    if args.action == 'export':
        # User wants to export friends
        export_friends(api, user)
    elif args.action == 'import':
        # User wants to import friends
        import_friends(api, user, bool(args.notifications))
    else:
        # This should never happen, but...
        raise Exception("Undefined action: Should be 'import' or 'export'")

    # Exit with 0 exit code
    sys.exit()

# Actually run the main() function and catch any exceptions
try:
    main()
except Exception, e:
    print >> sys.stderr, e
    sys.exit(1)

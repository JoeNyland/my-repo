#!/usr/bin/env python
# -*- coding: utf-8 -*-

__doc__ = 'Updates an AWS Route53 A record to the current public IP of the machine'

from sys import stderr, exit
from argparse import ArgumentParser
from boto.route53.connection import Route53Connection
from boto.route53.record import ResourceRecordSets
from requests import get


# Process commandline arguments
parser = ArgumentParser()
parser.add_argument('--record', '-r', dest='record', required='yes')
parser.add_argument('--zone-id', '-z', dest='zone_id', required='yes')
parser.add_argument('--access-key-id', '-i', dest='id', required='yes')
parser.add_argument('--access-key', '-k', dest='key', required='yes')
args = parser.parse_args()


def connect(key_id, key_secret):
    # Connect to Route53
    connection = Route53Connection(key_id, key_secret)
    if connection is not None:
        # If the connection to AWS has been established, return the connection object
        return connection
    else:
        # Else, raise an exception with a meaningful message
        msg = "Failed to connect to the Route53 using the supplied credentials."
        raise Exception(msg)


def get_ip():
    # Get the current IP
    ip = get('http://icanhazip.com').content.rstrip()
    if ip is not None:
        # If the current IP has been obtained, return it
        return ip
    else:
        # Else, raise an exception with a meaningful message
        msg = 'Failed to get the current IP address'
        raise Exception(msg)


def main():
    # Add the current IP to the requested security group by running the main() function
    conn = connect(args.id, args.key)
    ip = get_ip()

    if conn is not None:
        # If a connection to Route53 has been returned from connect(), check to see if the record exists
        current = conn.get_all_rrsets(args.zone_id, 'A', args.record, maxitems=1)[0]
        if len(current.resource_records) == 1 and current.resource_records[0] != ip:
            # The new record is different, so we need to delete the current version from Route53 and create a new one
            old_ip = current.resource_records                                       # Capture the old IP from Route53
            changes = route53.record.ResourceRecordSets(connection, args.zone_id)   # Initialise a changes object
            delete_record = changes.add_change("DELETE", args.record, 'A', 60)      # Add a change to delete the current record
            delete_record.add_value(old_ip[0])                                      # Add the old IP to the delete charge
            create_record = changes.add_change("CREATE", args.record, 'A', 1)       # Add a change to create the new record
            create_record.add_value(ip)                                             # Add the new IP to the create charge
            changes.commit()
        else:
            print 'The current record in Route53 is already set to the current IP'

    else:
        # Else, raise an exception with a meaningful message
        raise Exception('Failed to connect to Route53')

# Actually run main()
try:
    # Try main()
    main()
except Exception, e:
    if hasattr(e, 'error_message'):
        # If an exception has been raised, check if the error_message attr has been set and print.
        print >> stderr, e.error_message.capitalize()
    else:
        # If not, print the exception error message
        print >> stderr, e
    exit(1)
else:
    exit(0)

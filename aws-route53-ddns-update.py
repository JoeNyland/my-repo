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
parser.add_argument('--ttl', '-t', dest='ttl', default=60)
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
    new_ip = get_ip()

    if conn is not None:
        # If a connection to Route53 has been returned from connect(), check to see if the record exists
        current = conn.get_all_rrsets(args.zone_id, 'A', args.record, maxitems=1)[0]

        changes = ResourceRecordSets(conn, args.zone_id)                                  # Initialise a changes object
        current_rname = str(current.name)                                                 # Capture the name of the current record returned
        current_rip = str(current.resource_records[0])                                    # Capture the value of the current record returned
        current_rttl = int(current.ttl)                                                   # Capture the TTL of the current record returned

        if current_rname == args.record and ( current_rip != new_ip or ( current_rip == new_ip and current_rttl != args.ttl ) ):
            # The record currently exists, but the IP or TTL is different so we need to delete the current record first
            delete_record = changes.add_change('DELETE', args.record, 'A', current_rttl)  # Add a change to delete the current record
            delete_record.add_value(current_rip)                                          # Add the old IP to the delete charge
            # Now create a new one
            create_record = changes.add_change('CREATE', args.record, 'A', args.ttl)      # Add a change to create the new record
            create_record.add_value(new_ip)                                               # Add the new IP to the create charge
        elif current_rname != args.record:
            # The record does not currently exist, creating a new one
            create_record = changes.add_change('CREATE', args.record, 'A', args.ttl)      # Add a change to create the new record
            create_record.add_value(new_ip)                                               # Add the new IP to the create charge
        else:
            print 'The current record in Route53 is already up to date'
            return True

        if changes.commit():
            print 'Successfully set the hostname ' + args.record + ' to the IP ' + new_ip + ' with the TTL ' + str(args.ttl)
            return True

    else:
        # Else, raise an exception with a meaningful message
        raise Exception('Failed to connect to Route53')

# Actually run main()
try:
    # Try main()
    main()
except Exception, e:
    # If not, print the exception error message
    print >> stderr, e
    exit(1)
else:
    exit(0)

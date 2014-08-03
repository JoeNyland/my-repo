#!/usr/bin/env python
# -*- coding: utf-8 -*-

__doc__ = 'Updates an AWS EC2 Security Group to allow *all* traffic from the public IP of the machine'

from sys import stderr, exit
from argparse import ArgumentParser

from boto import ec2
from requests import get


# Process commandline arguments
parser = ArgumentParser()
parser.add_argument('--region', '-r', default='us-west-1', required='yes')
parser.add_argument('--access-key-id', '-i', dest='id', required='yes')
parser.add_argument('--access-key', '-k', dest='key', required='yes')
parser.add_argument('--security-group', '-g', dest='group', required='yes')
args = parser.parse_args()


def connect(region, key_id, key):
    # Connect to EC2
    connection = ec2.connect_to_region(region_name=region, aws_access_key_id=key_id, aws_secret_access_key=key)
    if connection is not None:
        # If the connection to AWS has been established, return the connection object
        return connection
    else:
        # Else, raise an exception with a meaningful message
        msg = "Failed to connect to the region '" + region + "' using the supplied credentials."
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


def get_cidr(mask=32):
    # Convert ip to a CIDR formatted IP, defaults to /32
    ip = get_ip()
    cidr = ip + '/' + str(mask)
    return cidr


def main(group):
    # Add the current IP to the requested security group by running the main() function
    connection = connect(args.region, args.id, args.key)
    if connection is not None:
        # If a connection to AWS has been returned from connect(), try to add the rule
        connection.authorize_security_group(group_name=group, ip_protocol='-1', from_port=0, to_port=65335,
                                            cidr_ip=get_cidr())
    else:
        # Else, raise an exception with a meaningful message
        raise Exception('Failed to connect to ')

# Actually run main()
try:
    # Try main()
    main(args.group)
except Exception, e:
    if hasattr(e, 'error_message'):
        # If an exception has been raised, check if the error_message attr has been set and print.
        print >> stderr, e.error_message.capitalize()
    else:
        # If not, print the exception error message
        print >> stderr, e
    exit(1)
else:
    # main() ran ok, so tell the user
    print 'Successfully added your current IP address (' + get_ip() + ") to the AWS security group '" \
          + args.group + "' in the region '" + args.region + "'."
    exit(0)

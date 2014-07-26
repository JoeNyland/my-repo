#!/usr/bin/env python
__doc__ = 'Updates an AWS EC2 Security Group to allow *all* traffic from the public IP of the machine'




from sys import stderr, exit
from argparse import ArgumentParser

from boto import ec2
from requests import get


# Process commandline arguments
parser = ArgumentParser()
parser.add_argument('--region', '-r', default='us-west-1', required='yes')
parser.add_argument('--aws-access-key-id', '-i', dest='id', required='yes')
parser.add_argument('--aws-access-key', '-k', dest='key', required='yes')
parser.add_argument('--aws-security-group', '-g', dest='group', required='yes')
args = parser.parse_args()


def connect(region, key_id, key):
    # Connect to EC2
    connection = ec2.connect_to_region(region_name=region, aws_access_key_id=key_id, aws_secret_access_key=key)
    if connection is not None:
        return connection
    else:
        msg = "Failed to connect to the region '" + region + "' using the supplied credentials."
        raise Exception(msg)


def get_ip():
    # Try to get the current IP
    ip = get('http://icanhazip.com').content.rstrip()
    if ip is not None:
        return ip
    else:
        msg = 'Failed to get the current IP address'
        raise Exception(msg)


def get_cidr(mask=32):
    # Convert ip to a CIDR formatted IP, defaults to /32
    ip = get_ip()
    cidr = ip + '/' + str(mask)
    return cidr


def main(group):
    # Try to add the current IP to the requested security group by running the main() function
    connection = connect(args.region, args.id, args.key)
    if connection is not None:
        connection.authorize_security_group(group_name=group, ip_protocol='-1', from_port=0, to_port=65335,
                                            cidr_ip=get_cidr())
    else:
        raise Exception('Failed to connect to ')

# Actually run main()
try:
    main(args.group)
except Exception, e:
    if hasattr(e, 'error_message'):
        print >> stderr, e.error_message.capitalize()
    else:
        print >> stderr, e
    exit(1)
else:
    print 'Successfully added your current IP address (' + get_ip() + ") to the AWS security group '" + args.group + "' in the region '" + args.region + "'."
    exit(0)

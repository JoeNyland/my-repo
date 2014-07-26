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

# Try to connect to EC2
try:
    ec2 = ec2.connect_to_region(region_name=args.region, aws_access_key_id=args.id, aws_secret_access_key=args.key)
except Exception, e:
    print >> stderr, e
    exit(1)

# Try to get the current IP
try:
    ip = get('http://icanhazip.com').content.rstrip()
except Exception, e:
    print >> stderr, e
    exit(1)
else:
    cidr = ip + '/32'

# Try to add the current IP to the requested security group
try:
    ec2.authorize_security_group(group_name=args.group, ip_protocol=-1, from_port=0, to_port=65335, cidr_ip=cidr)
except Exception, e:
    print >> stderr, e.error_message.capitalize()
    exit(1)
else:
    print 'Successfully added your current IP address (' + ip + ") to the AWS security group '" + args.group + "' in the region '" + args.region + "'."
    exit(0)

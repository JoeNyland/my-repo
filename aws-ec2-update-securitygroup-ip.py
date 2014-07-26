#!/usr/bin/env python
__doc__ = 'Updates an AWS EC2 Security Group to allow *all* traffic from the public IP of the machine'



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

# Connect to EC2
ec2 = ec2.connect_to_region(region_name=args.region, aws_access_key_id=args.id, aws_secret_access_key=args.key)

# Get the current IP
ip = get('http://icanhazip.com').content.rstrip() + '/32'

# Add the current IP to the requested security group
ec2.authorize_security_group(group_name=args.group, ip_protocol=-1, from_port=0, to_port=65335, cidr_ip=ip)

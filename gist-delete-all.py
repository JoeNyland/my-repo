#!/usr/bin/env python
# -*- coding: utf-8 -*-

__doc__ = "Deletes all of the Gists for the provided user."

from sys import stderr,exit
from argparse import ArgumentParser
import github3

parser = ArgumentParser()
parser.add_argument('-u', '--username', dest='u', required='yes')
parser.add_argument('-p', '--password', dest='p', required='yes')
args = parser.parse_args()

try:
    gh = github3.login(args.u, args.p)
    u = gh.user()
    if u.public_gists > 0 or u.total_private_gists > 0:
        print 'Deleting all of the Gists for the user ' + u.login + '...'
        for g in gh.iter_gists():
            if g.delete():
                print 'Deleted Gist ' + g.id
            else:
                raise Exception('Failed to delete Gist ' + g.id)
    else:
        raise Exception('The user ' + u.login + ' does not have any Gists to delete.')
except Exception, e:
    print >> stderr, e
    exit(1)
else:
    print 'Successfully deleted all of the Gists for the user ' + u.login + '.'
    exit(0)

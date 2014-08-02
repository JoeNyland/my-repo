#!/usr/bin/env python
# -*- coding: utf-8 -*-

__doc__ = "Creates Gists from files"


from sys import stderr, exit
from argparse import ArgumentParser
from github3 import login

parser = ArgumentParser()
parser.add_argument('-u', '--username', dest='u', required='yes')
parser.add_argument('-p', '--password', dest='p', required='yes')
parser.add_argument('-s', '--secret', dest='s', action='store_true', default=False)
parser.add_argument('files', nargs='+', action='append')
args = parser.parse_args()

try:
    gh = login(args.u, args.p)
    u = gh.user()
    pub = not args.s
    x = 0
    print 'Uploading Gists for ' + u.login + '...'
    for f in args.files[0]:
        fh = open(f, 'r')
        c = fh.read()
        gf = {
            f: {'content': c}
        }
        fh.close()
        print 'Uploading ' + f
        if gh.create_gist(description=None, files=gf, public=pub):
            x += 1
except Exception, e:
    print >> stderr, e
    exit(1)
else:
    print 'Successfully uploaded ' + str(x) + ' Gist(s) for the user ' + u.login + '.'
    exit(0)

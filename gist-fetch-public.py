#!/usr/bin/env python

__doc__ = "Clone all of a user's Gists. Use: `USERNAME={GitHub User Name} ./gist-fetch-public.py`"

__credits__ = "'Fedir': https://raw.github.com/gist/5466075/gist-backup.py," \
              "'saranicole': https://raw.github.com/gist/5466075/gist-backup.py"


import json
import urllib
from subprocess import call
from urllib import urlopen
import os
import math

# TODO: Rewrite this script to use github3.py library.
# TODO: Rename to gist-clone-all.py and add option to clone public/private/all Gists

USERNAME = os.environ['USERNAME']

perpage=30.0
userurl = urlopen('https://api.github.com/users/' + USERNAME)
public_gists = json.load(userurl)
gistcount = public_gists['public_gists']
pages = int(math.ceil(float(gistcount)/perpage))

for page in range(pages):
    u = urlopen('https://api.github.com/users/' + USERNAME  + '/gists?page=' + str(page) + '&per_page=' + str(int(perpage)))
    gists = json.load(u)
    startd = os.getcwd()

    for gist in gists:
      gistd = gist['id']
      if os.path.isdir(gistd):
        os.chdir(gistd)
        call(['git', 'pull', 'git://gist.github.com/' + gistd + '.git'])
        os.chdir(startd)
      else:
        call(['git', 'clone', 'git://gist.github.com/' + gistd + '.git'])

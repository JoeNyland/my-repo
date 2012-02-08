#!/bin/bash

# Script created by Joe Nyland on 08/02/2012 to update Bacula pools with new settings, then update all volume paramters.

#
# Sample set of commands for pool 'x':
# 
# 
# 
# 
#

$BACULADIR=`which bacula-dir`

$BACULADIR << EOPFR
update
2
43
update
2
44
update
2
45
quit
EOPFR

$BACULADIR << EOVP
update
1
14
quit
EOVP

#$BACULADIR << EOREC
#
#EOREC